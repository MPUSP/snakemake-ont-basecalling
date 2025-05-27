# -----------------------------------------------------
# generate single summary file
# -----------------------------------------------------
rule prepare_summary:
    input:
        get_all_summary,
    output:
        "results/{run}/dorado_summary/all_summary.txt",
    threads: 1
    log:
        "results/{run}/dorado_summary/all_summary.log",
    shell:
        "(head -n 1 {input[0]}; "
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
    threads: 1
    log:
        "results/{run}/report/pycoQC_report.log",
    threads: 1
    wrapper:
        "https://raw.githubusercontent.com/MPUSP/mpusp-snakemake-wrappers/refs/heads/main/pycoqc"
