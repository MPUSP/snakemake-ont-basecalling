# -----------------------------------------------------
# module to download the basecalling model if needed
# -----------------------------------------------------
rule download_model:
    output:
        flag=touch(os.path.join(LOG, "{run}", "flags", "dorado_download.finished")),
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
# module to collect all summary files
# -----------------------------------------------------
rule summarize_barcodes:
    input:
        get_input_summarized_barcodes,
    output:
        summary=os.path.join(OUTPUT, "{run}", "dorado_summary", "all_summary.txt"),
    log:
        os.path.join(LOG, "{run}", "dorado_summary", "summarize_all.log"),
    shell:
        "cat {input} > {output.summary} 2> {log}"


# -----------------------------------------------------
# checkpoint rule that collects all barcodes
# -----------------------------------------------------
checkpoint generate_barcodes:
    input:
        summary=os.path.join(OUTPUT, "{run}", "dorado_summary", "all_summary.txt"),
    output:
        barcodes=os.path.join(OUTPUT, "{run}", "dorado_barcodes", "all_barcodes.txt"),
    log:
        os.path.join(LOG, "{run}", "dorado_barcodes", "generate_barcodes.log"),
    shell:
        """
        cut -f 12 {input.summary} | 
        sort | uniq | 
        grep -v ^barcode > {output.barcodes} 2> {log};
        while IFS= read -r line; do
            touch $(dirname {output.barcodes})/$line.txt
        done < {output.barcodes}
        """


# -----------------------------------------------------
# module to demultiplex dorado basecall files
# -----------------------------------------------------
rule dorado_demux:
    input:
        bam=os.path.join(OUTPUT, "{run}", "dorado_basecall", "{file}.bam"),
    output:
        fastqs=directory(os.path.join(OUTPUT, "{run}", "dorado_demux", "{file}")),
        flag=touch(
            os.path.join(LOG, "{run}", "flags", "{file}", "dorado_demux.finished")
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
        flag=touch(os.path.join(LOG, "{run}", "flags", "dorado_demux.finished")),


# -----------------------------------------------------
# module to merge and bgzip fastq files
# -----------------------------------------------------
rule merge_and_bgzip_fastqs:
    input:
        flag=rules.collect_dorado_demux.output.flag,
        fastqs=get_fastqs,
    output:
        compressed=os.path.join(OUTPUT, "{run}", "merged_fastqs", "{barcode}.fastq.gz"),
    conda:
        "../envs/samtools.yml"
    log:
        os.path.join(LOG, "{run}", "merge_and_bgzip", "{barcode}.log"),
    shell:
        "mkdir -p $(dirname {output.compressed}); "
        "cat {input.fastqs} | bgzip -c > {output.compressed} 2> {log}"


# ----------------------------------------------------------------------------
# module that collects all merged barcode fastq files and creates a flag file
# ----------------------------------------------------------------------------
rule collect_merged_fastqs:
    input:
        aggregate_merged_fastqs,
    output:
        flag=touch(os.path.join(LOG, "{run}", "flags", "dorado_merged_fastqs.finished")),
