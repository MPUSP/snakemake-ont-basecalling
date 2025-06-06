# -----------------------------------------------------
# generate single summary file
# -----------------------------------------------------
rule prepare_summary:
    input:
        get_all_summary,
    output:
        "results/{run}/dorado_summary/all_summary.txt",
    conda:
        "../envs/base.yml"
    log:
        "results/{run}/dorado_summary/all_summary.log",
    shell:
        "firstfile=`echo {input} | cut -f 1 -d ' '`;"
        "(head -n 1 ${{firstfile}}; "
        "tail -n +2 -q {input}) > {output} 2> {log}"


# -----------------------------------------------------
# generate quality control report using pycoQC
# -----------------------------------------------------
rule pycoQC_report:
    input:
        summary=rules.prepare_summary.output,
    output:
        report_html="results/{run}/report/pycoQC_report.html",
        report_json="results/{run}/report/pycoQC_report.json",
    log:
        "results/{run}/report/pycoQC_report.log",
    wrapper:
        "https://raw.githubusercontent.com/MPUSP/mpusp-snakemake-wrappers/refs/heads/main/pycoqc"


# -----------------------------------------------------
# generate quality control report using NanoPlot
# -----------------------------------------------------
rule nanoplot_report:
    input:
        summary=rules.prepare_summary.output,
    output:
        report="results/{run}/report/NanoPlot_report.html",
    log:
        "results/{run}/report/NanoPlot_report.log",
    threads: 1
    params:
        extra="--no_static --only-report",
    wrapper:
        "https://raw.githubusercontent.com/MPUSP/mpusp-snakemake-wrappers/refs/heads/main/nanoplot"
