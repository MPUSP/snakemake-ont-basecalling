# -----------------------------------------------------
# demultiplex dorado basecall files
# -----------------------------------------------------
rule dorado_demux:
    input:
        bam="results/{run}/dorado_simplex/{run}_merged.bam",
    output:
        demux=directory("results/{run}/dorado_demux"),
        flag="results/{run}/dorado_demux/dorado_demux.finished",
    params:
        dorado=config["dorado"]["path"],
        cuda=config["dorado"]["simplex"]["cuda"],
        mod_model=lambda wc: check_mod_model(wc),
    conda:
        "../envs/base.yml"
    threads: int(workflow.cores * 0.5)
    log:
        "results/{run}/dorado_demux/{run}_demux.log",
    shell:
        """
        mkdir -p {output.demux};
        if [ '{params.mod_model}' != 'None' ]; then \
        {params.dorado} demux \
        --threads {threads} \
        --output-dir {output.demux} \
        --no-classify \
        {input.bam} 2> {log};
        else \
        {params.dorado} demux \
        --threads {threads} \
        --output-dir {output.demux} \
        --no-classify \
        --emit-fastq \
        {input.bam} 2> {log};
        fi;
        find {output.demux} -mindepth 4 -type d -path '*/barcode*' -print0 | xargs -0 -I{{}} mv {{}} {output.demux};
        find {output.demux} -mindepth 4 -type d -path '*/unclassified' -print0 | xargs -0 -I{{}} mv {{}} {output.demux};
        touch {output.flag}
        """


# -----------------------------------------------------
# prepare fastq files by barcode
# -----------------------------------------------------
rule prepare_fastq:
    input:
        flag=rules.dorado_demux.output.flag,
        file=get_demuxed_file,
    output:
        "results/{run}/dorado_aggregate/{barcode}.fastq",
    conda:
        "../envs/samtools.yml"
    threads: int(workflow.cores * 0.2)
    params:
        mod_model=lambda wc: check_mod_model(wc),
    log:
        "results/{run}/dorado_aggregate/{barcode}.log",
    shell:
        "if [ '{params.mod_model}' != 'None' ]; then "
        "echo 'extract fastq with modified base tag from BAM file.' > {log}; "
        "samtools fastq {input.file} "
        "-T RG,MM,ML "
        "-@ {threads} > {output} 2>> {log}; "
        "else "
        "echo 'copy fastq file.' > {log} 2>&1; "
        "cp {input.file} > {output} 2>> {log}; "
        "fi;"


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
