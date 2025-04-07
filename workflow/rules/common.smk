# read runs files
runs = pd.read_csv(config["runs"], sep=",").set_index("run_id", drop=False)


# -----------------------------------------------------
# helper functions
# -----------------------------------------------------
def get_pod5(wildcards):
    # get the input pod5 file
    return os.path.join(
        runs.loc[wildcards.run, "data_folder"], wildcards.file + ".pod5"
    )


def get_run(wildcards):
    # get the run id
    return runs.loc[wildcards.run, "run_id"]


def get_file_names(wildcards):
    # get the file names
    return INPUT_FILE_NAME_NO_EXT[wildcards.run]


def get_input_summarized_barcodes(wildcards):
    # get the input files for the summarize_barcodes rule
    return expand(
        rules.dorado_summary.output,
        run=get_run(wildcards),
        file=get_file_names(wildcards),
    )


def get_barcode_list(wildcards):
    # access the output of the checkpoint to dynamically retrieve the list of barcodes
    checkpoint_output = checkpoints.generate_barcodes.get(
        run=wildcards.run
    ).output.barcodes

    # Read the barcodes from the generated file
    with open(checkpoint_output) as f:
        barcodes = [line.strip() for line in f]
    return barcodes


def get_barcode(wildcards):
    # access the output of the checkpoint to dynamically retrieve the barcode
    checkpoint_output = checkpoints.generate_barcodes.get(
        run=wildcards.run
    ).output.barcodes

    return glob_wildcards(
        os.path.join(os.path.abspath(checkpoint_output), "{barcode}.txt")
    ).barcode


def aggregate_dorado_demux(wildcards):
    return expand(
        rules.dorado_demux.output.fastqs,
        run=get_run(wildcards),
        file=get_file_names(wildcards),
    )


def get_fastqs(wildcards):
    # dynamically find FASTQ files for the given run_id, files, and barcode
    fastqs = []
    for file in INPUT_FILE_NAME_NO_EXT[wildcards.run]:
        fastqs.append(
            glob.glob(
                os.path.join(
                    OUTPUT,
                    wildcards.run,
                    "dorado_demux",
                    file,
                    f"*_{wildcards.barcode}.fastq",
                )
            )
        )
    return list(itertools.chain.from_iterable(fastqs))


def aggregate_merged_fastqs(wildcards):
    return expand(
        rules.merge_and_bgzip_fastqs.output.compressed,
        run=get_run(wildcards),
        barcode=get_barcode_list(wildcards),
    )
