# -----------------------------------------------------
# module to download the basecalling model if needed
# -----------------------------------------------------
rule download_model:
    output:
        flag=touch(os.path.join(LOG, "{run}", "flags", "dorado_download.flag")),
    params:
        dorado=os.path.normpath(config["dorado"]["path"]),
        model=lambda wc: runs.loc[wc.run, "basecalling_model"],
        model_dir=os.path.join(OUTPUT, "model"),
    log:
        os.path.join(LOG, "{run}", "dorado_download_model", "dorado_download.log"),
    shell:
        "mkdir -p {params.model_dir} && "
        "{params.dorado} download "
        "--model {params.model} "
        " --models-directory {params.model_dir} 2> {log}"


# -----------------------------------------------------
# module to basecall reads using dorado
# -----------------------------------------------------
rule dorado_simplex:
    input:
        model=rules.download_model.output.flag,
        file=get_pod5,
    output:
        bam=os.path.join(OUTPUT, "{run}", "dorado_basecall", "{file}.bam"),
    threads: workflow.cores
    log:
        os.path.join(LOG, "{run}", "dorado_basecall", "{file}.log"),
    params:
        outdir=os.path.join(OUTPUT, "{run}"),
        dorado=config["dorado"]["path"],
        model=lambda wc: runs.loc[wc.run, "basecalling_model"],
        model_dir=os.path.abspath(os.path.join(OUTPUT, "model")),
        barcode_kit=lambda wc: runs.loc[wc.run, "barcode_kit"],
        cuda=config["dorado"]["simplex"]["cuda"],
        trim=config["dorado"]["simplex"]["trim"],
    shell:
        "{params.dorado} basecaller "
        "--device {params.cuda} "
        "--kit-name {params.barcode_kit} "
        "--trim {params.trim} "
        "{params.model_dir}/{params.model} "
        "{input.file} > {output.bam} 2> {log}"


# -----------------------------------------------------
# module to summarize basecalled reads using dorado
# -----------------------------------------------------
rule dorado_summary:
    input:
        rules.dorado_simplex.output.bam,
    output:
        os.path.join(OUTPUT, "{run}", "dorado_summary", "{file}.summary"),
    log:
        os.path.join(LOG, "{run}", "dorado_summary", "{file}.log"),
    params:
        dorado=config["dorado"]["path"],
    shell:
        "{params.dorado} summary "
        "{input} > {output} 2> {log}"


# -----------------------------------------------------
# module to collect all barcodes
# -----------------------------------------------------
rule summarize_barcodes:
    input:
        get_input_summariezed_barcodes,
    output:
        summary=os.path.join(OUTPUT, "{run}", "dorado_summary", "all_summary.txt"),
        barcodes=os.path.join(OUTPUT, "{run}", "dorado_summary", "barcodes.txt"),
    threads: workflow.cores
    log:
        os.path.join(LOG, "{run}", "dorado_summary", "summarize_barcodes.log"),
    shell:
        "cat {input} > {output.summary}; "
        "cut -f 12 {output.summary} | "
        "sort | uniq | "
        "grep -v ^barcode > {output.barcodes} 2> {log}"


# -----------------------------------------------------
# module to demultiplex dorado basecall files
# -----------------------------------------------------
rule dorado_demux:
    input:
        bam=os.path.join(OUTPUT, "{run}", "dorado_basecall", "{file}.bam"),
    output:
        fastqs=directory(os.path.join(OUTPUT, "{run}", "dorado_demux", "{file}")),
        flag=touch(
            os.path.join(LOG, "{run}", "flags", "{file}", "dorado_demux_finished.flag")
        ),
    threads: workflow.cores
    log:
        os.path.join(LOG, "{run}", "dorado_demux", "{file}.log"),
    params:
        dorado=config["dorado"]["path"],
        cuda=config["dorado"]["simplex"]["cuda"],
    shell:
        "mkdir -p {output.fastqs} && "
        "{params.dorado} demux "
        "--emit-fastq "
        "--output-dir {output.fastqs} "
        "--no-classify "
        "{input.bam} 2> {log} "


# -------------------------------------------------------------------
# module that collects all dorado fastq files and creates a flag file
# -------------------------------------------------------------------
rule collect_dorado_demux:
    input:
        aggregate_dorado_demux,
    output:
        flag=touch(os.path.join(LOG, "{run}", "flags", "dorado_demux_finished.flag")),
