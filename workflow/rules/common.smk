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
# helper function
# -----------------------------------------------------
def check_dorado_version(dorado_path, min_dorado_version):
    import subprocess

    version_cmd = [dorado_path, "--version"]
    try:
        run_cmd = subprocess.run(version_cmd, capture_output=True, text=True)
    except FileNotFoundError:
        raise FileNotFoundError(
            f"Dorado executable not found at '{dorado_path}'.\n\nPlease check your dorado installation path in the config file and re-run the workflow!\n"
        )

    if run_cmd.stdout == "":
        version_output = run_cmd.stderr.strip().split()[-1]
    else:
        version_output = run_cmd.stdout.strip().split()[-1]
    version_parts = version_output.split("+")[0].split(".")
    major = int(version_parts[0])
    minor = int(version_parts[1]) if len(version_parts) > 1 else 0
    patch = int(version_parts[2]) if len(version_parts) > 2 else 0
    version_tuple = (major, minor, patch)

    if version_tuple >= min_dorado_version:
        print(
            f"\n--- Detected dorado version: "
            f"{'.'.join(map(str, version_tuple))} ---\n"
        )
    else:
        raise ValueError(
            f"\n--- Detected dorado version "
            f"{'.'.join(map(str, version_tuple))} < {'.'.join(map(str, min_dorado_version))}. "
            f"Please update dorado to version >= {'.'.join(map(str, min_dorado_version))} and re-run the workflow. ---\n"
        )


def check_mod_model(wc):
    if "modified_bases_model" in runs.columns:
        if runs.loc[wc.run, "modified_bases_model"] != "-" or pd.notna(
            runs.loc[wc.run, "modified_bases_model"]
        ):
            return runs.loc[wc.run, "modified_bases_model"]
    else:
        return None


# -----------------------------------------------------
# input functions
# -----------------------------------------------------
def get_pod5(wildcards):
    return os.path.join(
        runs.loc[wildcards.run, "data_folder"],
        wildcards.file + config["input"]["file_extension"],
    )


def get_demuxed_file(wildcards):
    # parse file names
    file_ext = config["input"]["file_extension"]
    data_dir = runs.loc[wildcards.run, "data_folder"]
    pattern = f"{data_dir}/{{file}}{file_ext}"
    files = glob_wildcards(pattern).file

    # construct input targets
    file_type = []
    if check_mod_model(wildcards) is not None:
        file_type.append("bam")
        globs = glob_wildcards(
            os.path.join(
                "results/{run}/dorado_demux/barcode{barcode}",
                "{prefix}_barcode{barcode}_{suffix}_00000000_0.bam",
            )
        )
    else:
        file_type.append("fastq")
        globs = glob_wildcards(
            os.path.join(
                "results/{run}/dorado_demux/barcode{barcode}",
                "{prefix}_barcode{barcode}_{suffix}_00000000_0.fastq",
            )
        )

    result = expand(
        "results/{run}/dorado_demux/barcode{barcode}/{prefix}_barcode{barcode}_{suffix}_00000000_0.{filetype}",
        run=wildcards.run,
        file=files,
        prefix=list(set(globs.prefix)),
        barcode=wildcards.barcode,
        suffix=list(set(globs.suffix)),
        filetype=file_type,
    )
    # add empty dummy file in case a barcode is missing
    for f in list(set(result)):
        if not os.path.exists(f):
            os.makedirs(os.path.dirname(f), exist_ok=True)
            open(f, "w").close()
    return result


def get_barcoded_fastq(wildcards):
    if config["dorado"]["demultiplexing"]:
        result = expand(
            "results/{run}/dorado_aggregate/{barcode}.fastq.gz",
            run=wildcards.run,
            barcode=parse_barcodes(wildcards.run),
        )
    else:
        file_ext = config["input"]["file_extension"]
        run_dir = runs.loc[wildcards.run, "data_folder"]
        pattern = f"{run_dir}/{{file}}{file_ext}"
        files = glob_wildcards(pattern).file
        result = expand(
            "results/{run}/dorado_simplex/{file}.fastq.gz",
            run=wildcards.run,
            file=files,
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


def get_input_bams(wildcards):
    file_ext = config["input"]["file_extension"]
    run_dir = runs.loc[wildcards.run, "data_folder"]
    pattern = f"{run_dir}/{{file}}{file_ext}"
    files = glob_wildcards(pattern).file
    result = expand(
        "results/{run}/dorado_simplex/{file}.bam",
        run=wildcards.run,
        file=files,
    )
    return result


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
