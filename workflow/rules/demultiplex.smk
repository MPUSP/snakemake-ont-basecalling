# -----------------------------------------------------
# demultiplex dorado basecall files
# -----------------------------------------------------
rule dorado_demux:
    input:
        bam="results/{run}/dorado_simplex/{file}.bam",
    output:
        fastq=directory("results/{run}/dorado_demux/{file}"),
        flag="results/{run}/dorado_demux/{file}/demux.finished",
    params:
        dorado=config["dorado"]["path"],
        cuda=config["dorado"]["simplex"]["cuda"],
    conda:
        "../envs/base.yml"
    threads: 4
    log:
        "results/{run}/dorado_demux/{file}.log",
    shell:
        """
        mkdir -p {output.fastq};
        {params.dorado} demux \
        --threads {threads} \
        --emit-fastq \
        --output-dir {output.fastq} \
        --no-classify \
        {input.bam} 2> {log};
        find {output.fastq} -mindepth 4 -type f -name '*.fastq' -exec mv {{}} {output.fastq}/ \\;
        find {output.fastq} -mindepth 1 -type d -empty -delete;
        touch {output.flag}
        """


# -----------------------------------------------------
# collect demuxed fastq files (pseudo rule)
# -----------------------------------------------------
checkpoint collect_demuxed_fastq:
    input:
        get_demuxed_flag,
    output:
        "results/{run}/dorado_demux/demux_finished.txt",
    conda:
        "../envs/base.yml"
    threads: 1
    log:
        "results/{run}/dorado_demux/demux_finished.log",
    shell:
        """
        printf '%s\n' $(echo {input}) > {output} 2> {log};
        echo 'Collected FASTQ files:' >> {log};
        echo $(wc -l {output}) >> {log};
        """


# -----------------------------------------------------
# aggregate fastq files by filename
# -----------------------------------------------------
rule aggregrate_file:
    input:
        flag=rules.collect_demuxed_fastq.output,
        fastq=get_demuxed_fastq,
    output:
        fastq="results/{run}/dorado_aggregate/{barcode}.fastq",
    conda:
        "../envs/bgzip.yml"
    wildcard_constraints:
        file=config["input"]["file_regex"],
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
