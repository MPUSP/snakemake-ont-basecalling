# -----------------------------------------------------
# download the basecalling model if needed
# -----------------------------------------------------
rule download_model:
    output:
        flag="results/{run}/dorado_model/dorado_download.finished",
    params:
        dorado=os.path.normpath(config["dorado"]["path"]),
        model=lambda wc: runs.loc[wc.run, "basecalling_model"],
        model_dir="results/model",
    threads: 1
    log:
        "results/{run}/dorado_model/dorado_download.log",
    shell:
        "mkdir -p {params.model_dir} && "
        "{params.dorado} download "
        "--model {params.model} "
        "--models-directory {params.model_dir} 2> {log};"
        "touch {output.flag}"


# -----------------------------------------------------
# basecall reads using dorado
# -----------------------------------------------------
rule dorado_simplex:
    input:
        model=rules.download_model.output.flag,
        file=get_pod5,
    output:
        bam="results/{run}/dorado_simplex/{file}.bam",
    threads: 1
    # resources:
    #     gpu=1,
    log:
        "results/{run}/dorado_simplex/{file}.log",
    params:
        outdir="results/{run}",
        dorado=config["dorado"]["path"],
        model=lambda wc: runs.loc[wc.run, "basecalling_model"],
        model_dir=os.path.abspath("results/model"),
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
        "results/{run}/dorado_simplex/{file}.bam",
    output:
        "results/{run}/dorado_summary/{file}.summary",
    threads: 1
    log:
        "results/{run}/dorado_summary/{file}.log",
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
        bam="results/{run}/dorado_simplex/{file}.bam",
    output:
        fastqs=directory("results/{run}/dorado_demux/{file}"),
    threads: int(workflow.cores * 0.2)
    wildcard_constraints:
        file=config["input"]["file_regex"],  #"FBC.*_0.0000[01]",
    log:
        "results/{run}/dorado_demux/{file}.log",
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
# aggregate fastq files by prefix
# -----------------------------------------------------
rule aggregrate_prefix:
    input:
        fastq=get_prefixed_fastq,
    output:
        files="results/{run}/dorado_aggregate/prefix/{file}/{barcode}.fastq",
    conda:
        "../envs/bgzip.yml"
    log:
        "results/{run}/dorado_aggregate/prefix/{file}/{barcode}.log",
    shell:
        "cat {input.fastq} > {output.files} 2> {log}"


# -----------------------------------------------------
# aggregate fastq files by filename
# -----------------------------------------------------
rule aggregrate_file:
    input:
        fastq=get_filenamed_fastq,
    output:
        files="results/{run}/dorado_aggregate/file/{barcode}.fastq",
    conda:
        "../envs/bgzip.yml"
    log:
        "results/{run}/dorado_aggregate/file/{barcode}.log",
    shell:
        "cat {input.fastq} > {output.files} 2> {log}"


# -----------------------------------------------------
# collect results by barcode (pseudo rule)
# -----------------------------------------------------
rule aggregrate_barcode:
    input:
        fastq=get_barcoded_fastq,
    output:
        files="results/{run}/dorado_final/input_fastq.txt",
    conda:
        "../envs/bgzip.yml"
    log:
        "results/{run}/dorado_final/input_fastq.log",
    shell:
        "echo {input.fastq} > {output.files} 2> {log}"


# -----------------------------------------------------
# gzip merged fastq files
# -----------------------------------------------------
rule gzip:
    input:
        fastq="results/{run}/dorado_aggregate/file/{barcode}.fastq",
    output:
        fastq="results/{run}/dorado_aggregate/file/{barcode}.fastq.gz",
    conda:
        "../envs/bgzip.yml"
    threads: workflow.cores * 0.25
    log:
        "results/{run}/dorado_aggregate/file/{barcode}_gzip.log",
    shell:
        "cat {input.fastq} | bgzip --threads {threads} -c > {output.fastq} 2> {log}"
