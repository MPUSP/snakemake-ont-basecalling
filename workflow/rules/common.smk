# -----------------------------------------------------
# read table with run metadata
# -----------------------------------------------------
runs = pd.read_csv(config["input"]["runs"], sep=",").set_index("run_id", drop=False)


# -----------------------------------------------------
# input functions
# -----------------------------------------------------
def get_pod5(wildcards):
    return os.path.join(
        runs.loc[wildcards.run, "data_folder"],
        wildcards.file + config["input"]["file_extension"],
    )


def get_prefixed_fastq(wildcards):
    cp_out = checkpoints.dorado_demux.get(**wildcards).output[0]
    prefix = list(
        set(
            glob_wildcards(
                os.path.join(cp_out, "{prefix}_barcode{barcode}.fastq")
            ).prefix
        )
    )
    result = expand(
        "results/{run}/dorado_demux/{file}/{prefix}_barcode{barcode}.fastq",
        run=wildcards.run,
        file=wildcards.file,
        prefix=prefix,
        barcode=wildcards.barcode,
    )
    # add empty dummy file in case a barcode is missing
    for f in list(set(result)):
        if not os.path.exists(f):
            os.makedirs(os.path.dirname(f), exist_ok=True)
            open(f, "w").close()
    return result


def get_filenamed_fastq(wildcards):
    file_ext = config["input"]["file_extension"]
    run_dir = runs.loc[wildcards.run, "data_folder"]
    pattern = f"{run_dir}/{{file}}{file_ext}"
    files = glob_wildcards(pattern).file
    result = expand(
        "results/{run}/dorado_aggregate/prefix/{file}/{barcode}.fastq",
        run=wildcards.run,
        file=files,
        barcode=wildcards.barcode,
    )
    return result


def get_barcoded_fastq(wildcards):
    result = expand(
        "results/{run}/dorado_aggregate/file/{barcode}.fastq.gz",
        run=wildcards.run,
        barcode=config["input"]["barcodes"],
    )
    return result
