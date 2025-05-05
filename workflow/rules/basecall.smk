# -----------------------------------------------------
# download the basecalling model if needed
# -----------------------------------------------------
rule download_model:
    output:
        flag=touch(os.path.join(LOG, "{run}", "flags", "dorado_download.finished")),
    params:
        dorado=os.path.normpath(config["dorado"]["path"]),
        model=lambda wc: runs.loc[wc.run, "basecalling_model"],
        model_dir=os.path.join(OUTPUT, "model"),
    threads: 1
    log:
        os.path.join(LOG, "{run}", "dorado_download_model", "dorado_download.log"),
    shell:
        "mkdir -p {params.model_dir} && "
        "{params.dorado} download "
        "--model {params.model} "
        " --models-directory {params.model_dir} 2> {log}"


rule get_input_files:
    input:
        pod5=get_pod5_files,
    output:
        files=os.path.join(OUTPUT, "{run}", "dorado_input", "input_pod5_files.txt"),
    conda:
        "../envs/samtools.yml"
    log:
        os.path.join(LOG, "{run}", "dorado_input", "get_input_files.log"),
    shell:
        "du -h {input.pod5} > {output.files} 2> {log}"


# -----------------------------------------------------
# basecall reads using dorado
# -----------------------------------------------------
rule dorado_simplex:
    input:
        model=rules.download_model.output.flag,
        file=get_pod5,
    output:
        bam=os.path.join(OUTPUT, "{run}", "dorado_basecall", "{file}.bam"),
    threads: 1
    # resources:
    #     gpu=1,
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
# summarize basecalled reads using dorado
# -----------------------------------------------------
rule dorado_summary:
    input:
        rules.dorado_simplex.output.bam,
    output:
        os.path.join(OUTPUT, "{run}", "dorado_summary", "{file}.summary"),
    threads: 1
    log:
        os.path.join(LOG, "{run}", "dorado_summary", "{file}.log"),
    params:
        dorado=config["dorado"]["path"],
    shell:
        "{params.dorado} summary "
        "{input} > {output} 2> {log}"


# -----------------------------------------------------
# demultiplex dorado basecall files
# -----------------------------------------------------
checkpoint dorado_demux:
    input:
        bam=os.path.join(OUTPUT, "{run}", "dorado_basecall", "{file}.bam"),
    output:
        fastqs=directory(os.path.join(OUTPUT, "{run}", "dorado_demux", "{file}")),
    threads: int(workflow.cores * 0.2)
    wildcard_constraints:
        file="FBC.*_0.0000[01]",
    log:
        os.path.join(LOG, "{run}", "dorado_demux", "{file}.log"),
    params:
        dorado=config["dorado"]["path"],
        cuda=config["dorado"]["simplex"]["cuda"],
    shell:
        "mkdir -p {output.fastqs} && "
        "{params.dorado} demux "
        "--threads {threads} "
        "--emit-fastq "
        "--output-dir {output.fastqs} "
        "--no-classify "
        "{input.bam} 2> {log} "


# -----------------------------------------------------
# merge and bgzip fastq files
# -----------------------------------------------------
rule merge_and_bgzip:
    input:
        fastq=get_fastq_to_merge,
    output:
        fastq=os.path.join(
            OUTPUT, "{run}", "fastq_merged", "barcode_{barcode}.fastq.gz"
        ),
    conda:
        "../envs/samtools.yml"
    threads: workflow.cores
    log:
        os.path.join(LOG, "{run}", "merge_and_bgzip", "{barcode}.log"),
    shell:
        "mkdir -p $(dirname {output.fastq}); "
        "cat {input.fastq} | bgzip --threads {threads} -c > {output.fastq} 2> {log}"


rule get_merged_files:
    input:
        files=os.path.join(OUTPUT, "{run}", "dorado_input", "input_pod5_files.txt"),
        fastq=get_merged_fastq,
    output:
        files=os.path.join(OUTPUT, "{run}", "fastq_merged", "input_files.txt"),
    conda:
        "../envs/samtools.yml"
    log:
        os.path.join(LOG, "{run}", "merge_and_bgzip", "input_files.log"),
    shell:
        "du -h {input.fastq} > {output.files} 2> {log}"
