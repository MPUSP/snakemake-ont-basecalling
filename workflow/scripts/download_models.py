# DOWNLAOD MODELS
# -----------------------------------------------------------------------------
#
# This script downloads the specified basecalling model using dorado.

import subprocess
import sys
import shlex

dorado = snakemake.params.dorado
model = snakemake.params.model
mod_model = snakemake.params.mod_model
model_dir = snakemake.params.model_dir
output = str(snakemake.output.flag)
log = str(snakemake.log)

# make dir if not exists
subprocess.run(f"mkdir -p {shlex.quote(model_dir)}", shell=True)

# build command
if mod_model != "None":
    if "," in mod_model:
        mod_model = mod_model.split(",")
        for m in mod_model:
            cmd = [
                dorado,
                "download",
                "--model",
                m,
                "--models-directory",
                model_dir,
            ]
            with open(log, "a") as log_file:
                subprocess.run(cmd, stdout=log_file, stderr=log_file)
    else:
        cmd = [
            dorado,
            "download",
            "--model",
            mod_model,
            "--models-directory",
            model_dir,
        ]
        with open(log, "a") as log_file:
            subprocess.run(cmd, stdout=log_file, stderr=log_file)

cmd = [
    dorado,
    "download",
    "--model",
    model,
    "--models-directory",
    model_dir,
]
with open(log, "a") as log_file:
    subprocess.run(cmd, stdout=log_file, stderr=log_file)

# create finished flag
with open(output, "w") as f:
    f.write("Model download finished.\n")
