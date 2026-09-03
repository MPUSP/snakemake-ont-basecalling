# -----------------------------------------------------
# download the basecalling model using dorado
# -----------------------------------------------------
rule download_model:
    output:
        flag="results/{run}/dorado_model/dorado_download.finished",
    log:
        "results/{run}/dorado_model/dorado_download.log",
    conda:
        "../envs/base.yml"
    threads: 1
    params:
        dorado=os.path.normpath(config["dorado"]["path"]),
        model=lambda wc: runs.loc[wc.run, "basecalling_model"],
        mod_model=lambda wc: check_mod_model(wc),
        model_dir=config["dorado"]["model_dir"],
    script:
        "../scripts/download_models.py"


# -----------------------------------------------------
# basecall reads using dorado
# -----------------------------------------------------
rule dorado_simplex:
    input:
        model=rules.download_model.output.flag,
        file=get_pod5,
    output:
        bam="results/{run}/dorado_simplex/{file}.bam",
    log:
        "results/{run}/dorado_simplex/{file}.log",
    conda:
        "../envs/base.yml"
    threads: 1
    params:
        dorado=config["dorado"]["path"],
        model_dir=config["dorado"]["model_dir"],
        model=lambda wc: runs.loc[wc.run, "basecalling_model"],
        mod_model=lambda wc: (
            ",".join(
                [
                    os.path.join(config["dorado"]["model_dir"], m)
                    for m in check_mod_model(wc).split(",")
                ]
            )
            if check_mod_model(wc)
            else "None"
        ),
        barcode_kit=lambda wc: check_barcode_kit(wc),
        cuda=config["dorado"]["simplex"]["cuda"],
        trim=config["dorado"]["simplex"]["trim"],
        extra=config["dorado"]["simplex"].get("extra", ""),
    shell:
        "if [ '{params.mod_model}' != 'None' ]; then "
        "mod=`echo -e '--modified-bases-models {params.mod_model}'`; "
        "else "
        "mod=''; "
        "fi; "
        "if [ '{params.barcode_kit}' != 'None' ]; then "
        "barcode_kit=`echo -e '--kit-name {params.barcode_kit}'`; "
        "else "
        "barcode_kit=''; "
        "fi; "
        "{params.dorado} basecaller "
        "--device {params.cuda} "
        "${{barcode_kit}} "
        "--trim {params.trim} "
        "{params.extra} "
        "${{mod}} "
        "{params.model_dir}/{params.model} "
        "{input.file} > {output.bam} 2> {log}"


# -----------------------------------------------------
# aggregate bam files
# -----------------------------------------------------
rule aggregate_bam:
    input:
        bam=get_input_bams,
    output:
        merged_bam="results/{run}/dorado_simplex/{run}_merged.bam",
    log:
        "results/{run}/dorado_simplex/{run}_merge_bams.log",
    wildcard_constraints:
        file=config["input"]["file_regex"],
    conda:
        "../envs/samtools.yml"
    threads: workflow.cores * 0.5
    shell:
        "samtools merge -@ {threads} {output.merged_bam} {input.bam} 2> {log}"


# -----------------------------------------------------
# convert bam to fastq ONLY when not demultiplexing
# -----------------------------------------------------
rule samtools_bamtofq:
    input:
        rules.aggregate_bam.output.merged_bam,
    output:
        "results/{run}/dorado_simplex/{run}_merged.fastq",
    log:
        "results/{run}/dorado_simplex/{run}_bamtofq.log",
    conda:
        "../envs/samtools.yml"
    threads: int(workflow.cores * 0.5)
    params:
        mod_model=lambda wc: check_mod_model(wc),
    shell:
        "if [ '{params.mod_model}' != 'None' ]; then "
        "echo 'extract fastq with modified base tag from BAM file.' > {log}; "
        "samtools bam2fq {input} "
        "-T MM,ML "
        "-@ {threads} > {output} 2>> {log}; "
        "else "
        "echo 'extract standard fastq from BAM file.' > {log}; "
        "samtools bam2fq -@ {threads} {input} > {output} 2>> {log}; "
        "fi;"


# -----------------------------------------------------
# summarize basecalled reads using dorado
# -----------------------------------------------------
rule dorado_summary:
    input:
        rules.aggregate_bam.output.merged_bam,
    output:
        "results/{run}/dorado_summary/{run}.summary",
    log:
        "results/{run}/dorado_summary/{run}.log",
    conda:
        "../envs/base.yml"
    threads: 1
    params:
        dorado=config["dorado"]["path"],
    shell:
        "{params.dorado} summary " "{input} > {output} 2> {log}"


# -----------------------------------------------------
# gzip merged fastq files
# -----------------------------------------------------
rule gzip:
    input:
        fastq=branch(
            lookup(dpath="dorado/demultiplexing", within=config),
            then="results/{run}/dorado_aggregate/{barcode}.fastq",
            otherwise="results/{run}/dorado_simplex/{run}_merged.fastq",
        ),
    output:
        fastq=branch(
            lookup(dpath="dorado/demultiplexing", within=config),
            then="results/{run}/dorado_aggregate/{barcode}.fastq.gz",
            otherwise="results/{run}/dorado_simplex/{run}_merged.fastq.gz",
        ),
    log:
        branch(
            lookup(dpath="dorado/demultiplexing", within=config),
            then="results/{run}/dorado_aggregate/{barcode}_gzip.log",
            otherwise="results/{run}/dorado_simplex/{run}_gzip.log",
        ),
    conda:
        "../envs/bgzip.yml"
    threads: workflow.cores * 0.25
    shell:
        "cat {input.fastq} | "
        "bgzip --threads {threads} -c > "
        "{output.fastq} 2> {log}"
