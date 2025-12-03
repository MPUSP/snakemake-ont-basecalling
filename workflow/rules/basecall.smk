# -----------------------------------------------------
# download the basecalling model if needed
# -----------------------------------------------------
rule download_model:
    output:
        model=directory("results/{run}/dorado_model"),
        flag="results/{run}/dorado_model/dorado_download.finished",
    params:
        dorado=os.path.normpath(config["dorado"]["path"]),
        model=lambda wc: runs.loc[wc.run, "basecalling_model"],
        model_dir="results/model",
    conda:
        "../envs/base.yml"
    threads: 1
    log:
        "results/{run}/dorado_model/dorado_download.log",
    shell:
        "{params.dorado} download "
        "--model {params.model} "
        "--models-directory {output.model} 2> {log};"
        "touch {output.flag}"


# -----------------------------------------------------
# basecall reads using dorado
# -----------------------------------------------------
rule dorado_simplex:
    input:
        model=rules.download_model.output.flag,
        model_dir=rules.download_model.output.model,
        file=get_pod5,
    output:
        bam="results/{run}/dorado_simplex/{file}.bam",
    params:
        dorado=config["dorado"]["path"],
        model=lambda wc: runs.loc[wc.run, "basecalling_model"],
        barcode_kit=lambda wc: runs.loc[wc.run, "barcode_kit"],
        cuda=config["dorado"]["simplex"]["cuda"],
        trim=config["dorado"]["simplex"]["trim"],
        extra=config["dorado"]["simplex"].get("extra", ""),
    conda:
        "../envs/base.yml"
    threads: 1
    log:
        "results/{run}/dorado_simplex/{file}.log",
    shell:
        "{params.dorado} basecaller "
        "--device {params.cuda} "
        "--kit-name {params.barcode_kit} "
        "--trim {params.trim} "
        "{params.extra} "
        "{input.model_dir}/{params.model} "
        "{input.file} > {output.bam} 2> {log}"


# -----------------------------------------------------
# convert bam to fastq ONLY when not demultiplexing
# -----------------------------------------------------
rule samtools_bamtofq:
    input:
        "results/{run}/dorado_simplex/{file}.bam",
    output:
        "results/{run}/dorado_simplex/{file}.fastq",
    conda:
        "../envs/samtools.yml"
    threads: 1
    log:
        "results/{run}/dorado_simplex/{file}_bamtofq.log",
    shell:
        "samtools bam2fq {input} > {output} 2> {log}"


# -----------------------------------------------------
# summarize basecalled reads using dorado
# -----------------------------------------------------
rule dorado_summary:
    input:
        "results/{run}/dorado_simplex/{file}.bam",
    output:
        "results/{run}/dorado_summary/{file}.summary",
    params:
        dorado=config["dorado"]["path"],
    conda:
        "../envs/base.yml"
    threads: 1
    log:
        "results/{run}/dorado_summary/{file}.log",
    shell:
        "{params.dorado} summary "
        "{input} > {output} 2> {log}"


# -----------------------------------------------------
# gzip merged fastq files
# -----------------------------------------------------
rule gzip:
    input:
        fastq=branch(
            lookup(dpath="dorado/demultiplexing", within=config),
            then="results/{run}/dorado_aggregate/{barcode}.fastq",
            otherwise="results/{run}/dorado_simplex/{file}.fastq",
        ),
    output:
        fastq=branch(
            lookup(dpath="dorado/demultiplexing", within=config),
            then="results/{run}/dorado_aggregate/{barcode}.fastq.gz",
            otherwise="results/{run}/dorado_simplex/{file}.fastq.gz",
        ),
    conda:
        "../envs/bgzip.yml"
    threads: workflow.cores * 0.25
    log:
        branch(
            lookup(dpath="dorado/demultiplexing", within=config),
            then="results/{run}/dorado_aggregate/{barcode}_gzip.log",
            otherwise="results/{run}/dorado_simplex/{file}_gzip.log",
        ),
    shell:
        "cat {input.fastq} | "
        "bgzip --threads {threads} -c > "
        "{output.fastq} 2> {log}"
