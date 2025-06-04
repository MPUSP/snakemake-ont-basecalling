# -----------------------------------------------------
# read table with run metadata
# -----------------------------------------------------
runs = pd.read_csv(config["input"]["runs"], sep=",").set_index("run_id", drop=False)


# -----------------------------------------------------
# validate schema for config and run sheet
# -----------------------------------------------------
validate(config, "../../config/schemas/config.schema.yml")
validate(runs, "../../config/schemas/runs.schema.yml")


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
        barcode=parse_barcodes(wildcards.run),
    )
    return result


def parse_barcodes(run):
    bc_kit = runs.loc[run, "barcode_kit"]
    try:
        bc_max = int(bc_kit.split("-")[-1])
    except:
        bc_max = 96
    if not bc_max in [24, 96]:
        bc_max = 96
        print(
            "Warning: Max number of barcodes could not be ",
            f"determined from kit '{bc_kit}'.",
        )
    bc_string = config["input"]["barcodes"]
    barcodes = []
    # decompose short form to list by splitting at comma
    for bc in bc_string.split(","):
        if "-" in bc:
            bc_range = list(range(*[int(i) for i in bc.split("-")]))
            barcodes += bc_range + [bc_range[-1] + 1]
        else:
            barcodes += [int(bc)]

    if max(barcodes) > bc_max or min(barcodes) < 1:
        raise ValueError(
            f"Barcode numbers must be between 1 and {bc_max}. "
            "Please check config.yml -> input -> barcodes."
        )
    else:
        # convert integers to strings in 2-digit format
        barcodes = [format(i, "02") for i in barcodes]
        return barcodes


def get_all_summary(wildcards):
    file_ext = config["input"]["file_extension"]
    run_dir = runs.loc[wildcards.run, "data_folder"]
    pattern = f"{run_dir}/{{file}}{file_ext}"
    files = glob_wildcards(pattern).file
    result = expand(
        "results/{run}/dorado_summary/{file}.summary",
        run=wildcards.run,
        file=files,
    )
    return result
