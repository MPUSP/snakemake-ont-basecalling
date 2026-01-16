# -----------------------------------------------------
# generate quality control report using pycoQC
# -----------------------------------------------------
rule pycoQC_report:
    input:
        summary=rules.dorado_summary.output,
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
        summary=rules.dorado_summary.output,
    output:
        report="results/{run}/report/NanoPlot_report.html",
    log:
        "results/{run}/report/NanoPlot_report.log",
    threads: 1
    params:
        extra="--no_static --only-report",
    wrapper:
        "https://raw.githubusercontent.com/MPUSP/mpusp-snakemake-wrappers/refs/heads/main/nanoplot"
