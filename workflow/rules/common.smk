runs = pd.read_csv(config["runs"], sep=",").set_index("run_id", drop=False)


wildcard_constraints:
    run="|".join(runs.index),


# -----------------------------------------------------
# helper functions
# -----------------------------------------------------
def get_pod5(wildcards):
    # get the input pod5 file
    return os.path.join(runs.loc[wildcards.run, "data_folder"], wildcards.file + ".pod5")


def get_runs(wildcards):
    # get the run id
    return runs.loc[wildcards.run, "run_id"]


def get_file_names(wildcards):
    # get the file names
    return INPUT_FILE_NAME_NO_EXT[wildcards.run]


def aggregate_dorado_demux(wildcards):
    return expand(
        rules.dorado_demux.output.fastqs,
        run=get_runs(wildcards),
        file=get_file_names(wildcards),
    )


def get_input_summariezed_barcodes(wildcards):
    # get the input files for the summarize_barcodes rule
    return expand(
        rules.dorado_summary.output,
        run=get_runs(wildcards),
        file=get_file_names(wildcards),
    )
