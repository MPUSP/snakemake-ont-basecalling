# -----------------------------------------------------
# download the basecalling model using dorado
# -----------------------------------------------------
rule download_model:
    output:
        flag="results/{run}/dorado_model/dorado_download.finished",
    params:
        dorado=os.path.normpath(config["dorado"]["path"]),
        model=lambda wc: runs.loc[wc.run, "basecalling_model"],
        mod_model=lambda wc: check_mod_model(wc),
        model_dir=config["dorado"]["model_dir"],
    conda:
        "../envs/base.yml"
    threads: 1
    log:
        "results/{run}/dorado_model/dorado_download.log",
    shell:
        "mkdir -p {params.model_dir};"
        "if [ '{params.mod_model}' != 'None' ]; then "
        "echo 'Downloading modified bases model: {params.mod_model}' > {log}; "
        "{params.dorado} download "
        "--model {params.mod_model} "
        "--models-directory {params.model_dir} 2>> {log}; "
        "else "
        "echo 'No modified bases model specified.' >> {log}; "
        "echo 'Downloading bases model: {params.model}' >> {log}; "
        "{params.dorado} download "
        "--model {params.model} "
        "--models-directory {params.model_dir} 2>> {log}; "
        "fi; "
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
        "if [ '{params.mod_model}' != 'None' ]; then "
        "mod=`echo -e '--modified-bases-models {params.mod_model}'`; "
        "else "
        "mod=''; "
        "fi; "
        "{params.dorado} basecaller "
        "--device {params.cuda} "
        "--kit-name {params.barcode_kit} "
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
    conda:
        "../envs/samtools.yml"
    threads: workflow.cores * 0.5
    wildcard_constraints:
        file=config["input"]["file_regex"],
    log:
        "results/{run}/dorado_simplex/{run}_merge_bams.log",
    shell:
        "samtools merge -@ {threads} {output.merged_bam} {input.bam} 2> {log}"


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
        rules.aggregate_bam.output.merged_bam,
    output:
        "results/{run}/dorado_summary/{run}.summary",
    params:
        dorado=config["dorado"]["path"],
    conda:
        "../envs/base.yml"
    threads: 1
    log:
        "results/{run}/dorado_summary/{run}.log",
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
