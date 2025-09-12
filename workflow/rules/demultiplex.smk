# -----------------------------------------------------
# demultiplex dorado basecall files
# -----------------------------------------------------
checkpoint dorado_demux:
    input:
        bam="results/{run}/dorado_simplex/{file}.bam",
        summary="results/{run}/dorado_summary/{file}.summary",
    output:
        fastq=directory("results/{run}/dorado_demux/{file}"),
    params:
        dorado=config["dorado"]["path"],
        cuda=config["dorado"]["simplex"]["cuda"],
    conda:
        "../envs/base.yml"
    threads: int(workflow.cores * 0.2)
    wildcard_constraints:
        file=config["input"]["file_regex"],
    log:
        "results/{run}/dorado_demux/{file}.log",
    shell:
        "mkdir -p {output.fastq} && "
        "{params.dorado} demux "
        "--threads {threads} "
        "--emit-fastq "
        "--output-dir {output.fastq} "
        "--no-classify "
        "{input.bam} 2> {log} "


# -----------------------------------------------------
# aggregate fastq files by filename
# -----------------------------------------------------
rule aggregrate_file:
    input:
        fastq=get_demuxed_fastq,
    output:
        fastq="results/{run}/dorado_aggregate/{barcode}.fastq",
    conda:
        "../envs/bgzip.yml"
    log:
        "results/{run}/dorado_aggregate/{barcode}.log",
    shell:
        "cat {input.fastq} > {output.fastq} 2> {log}"


# -----------------------------------------------------
# collect results by barcode (pseudo rule)
# -----------------------------------------------------
rule aggregrate_barcode:
    input:
        fastq=get_barcoded_fastq,
    output:
        filelist="results/{run}/dorado_final/input_fastq.txt",
    conda:
        "../envs/bgzip.yml"
    log:
        "results/{run}/dorado_final/input_fastq.log",
    shell:
        "printf '%s\n' $(echo {input.fastq}) > {output.filelist} 2> {log}"
