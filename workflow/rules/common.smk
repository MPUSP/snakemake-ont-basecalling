# read runs files
runs = pd.read_csv(config["input"]["runs"], sep=",").set_index("run_id", drop=False)


# -----------------------------------------------------
# helper functions
# -----------------------------------------------------
def get_pod5(wildcards):
    return os.path.join(
        runs.loc[wildcards.run, "data_folder"], wildcards.file + ".pod5"
    )


def get_pod5_files(wildcards):
    res = []
    if not isinstance(wildcards.run, list):
        wc_runs = [wildcards.run]
    else:
        wc_runs = wildcards.run
    for run in wc_runs:
        run_dir = runs.loc[run, "data_folder"]
        res += directory(
            expand(
                os.path.join(OUTPUT, "{run}", "dorado_demux", "{file}"),
                run=run,
                file=glob_wildcards("{run_dir}/{file}.pod5").file,
            )
        )
    return res


def get_fastq_to_merge(wildcards):
    res = []
    if not isinstance(wildcards.run, list):
        wc_runs = [wildcards.run]
    else:
        wc_runs = wildcards.run
    for run in wc_runs:
        run_dir = runs.loc[run, "data_folder"]
        res += expand(
            os.path.join(
                OUTPUT,
                "{run}",
                "dorado_demux",
                "{file}",
                "{prefix}_barcode{barcode}.fastq",
            ),
            run=run,
            file=glob_wildcards("{run_dir}/{file}.pod5").file,
            prefix=glob_wildcards(
                os.path.join(
                    OUTPUT,
                    run,
                    "dorado_demux",
                    "{file}",
                    "{prefix}_barcode{barcode}.fastq",
                )
            ).prefix,
            barcode=wildcards.barcode,
        )
    res = [f for f in list(set(res)) if os.path.exists(f)]
    return res


def get_merged_fastq(wildcards):
    res = expand(
        os.path.join(OUTPUT, "{run}", "fastq_merged", "barcode_{barcode}.fastq.gz"),
        run=wildcards.run,
        barcode=glob_wildcards(
            os.path.join(
                OUTPUT,
                "{run}",
                "dorado_demux",
                "{file}",
                "{prefix}_barcode{barcode}.fastq",
            )
        ).barcode,
    )
    return res
