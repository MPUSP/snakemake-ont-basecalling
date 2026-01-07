## Running the workflow

### Input data

This workflow requires `pod5` input data. These input files are supplied to the workflow using a mandatory runs table linked in the `config.yml` file (default: `.test/config/runs.csv`). Each row in the runs table corresponds to a single run, for which all `pod5` files are provided via a `data_folder` column. Multiple runs can be defined in the table.
The runs table has the following layout:

| run_id      | data_folder  | basecalling_model                  | barcode_kit   |
| ----------- | ------------ | ---------------------------------- | ------------- |
| MK1C_run_01 | ".test/data" | dna_r10.4.1_e8.2_400bps_sup@v5.0.0 | SQK-PCB114-24 |

### Execution

To define rule specific resources like GPU usage, configuration profiles will be used.
See [snakemake docs](https://snakemake.readthedocs.io/en/stable/executing/cli.html#profiles) on profiles for more information.
A [default profile](workflow/profiles/default/config.yaml) for local testing and a slurm specific [cluster profile](workflow/profiles/slurm/config.yaml) is provided with this workflow.

To run the workflow from command line, change to the working directory and activate the conda environment.

```bash
cd snakemake-ont-basecalling
conda activate snakemake-ont-basecalling
```

Adjust options in the default config file `config/config.yml`.
Before running the entire workflow, perform a dry run using:

```bash
snakemake --cores 3 --sdm conda --directory .test --dry-run
```

To run the workflow with test files using **conda**:

```bash
snakemake --cores 3 --sdm conda --directory .test
```

To run the workflow with test files using **conda and apptainer**, set the dorado path to `/share/resources/dorado-<version>-linux-x64/bin/dorado` and make it available for apptainer using `bind`:

```bash
snakemake --cores 3 --sdm conda apptainer --directory .test --apptainer-args "--bind ../resources:/share/resources"
```

To run the workflow with test files on a **slurm cluster**, adjust the slurm-specific profile `workflow/profiles/slurm/config.yaml` file and run:

```bash
snakemake --cores 3 --sdm conda --workflow-profile workflow/profiles/slurm/ --directory .test
```

**Note:**
It is recommended to start the snakemake pipeline on the cluster using a session multiplexer like [screen](https://www.gnu.org/software/screen/manual/screen.html) or [tmux](https://www.redhat.com/en/blog/introduction-tmux-linux).

### Parameters

This table lists all parameters that can be used to run the workflow.

| Parameter        | Type   | Details                                   | Default                  |
| ---------------- | ------ | ----------------------------------------- | ------------------------ |
| **input**        |        |                                           |                          |
| runs             | string | table with sequencing runs                | `config/runs.csv`        |
| file_extension   | string | extension for input files                 | `pod5`                   |
| file_regex       | string | pattern to match input files              | `[A-Z]{3}[0-9]{5}...`    |
| barcodes         | string | used barcodes for demultiplexing          | `1-24`                   |
| **dorado**       |        |                                           |                          |
| path             | string | path to the Dorado executable             |                          |
| simplex / cuda   | string | CUDA device: `auto`, `cuda:0`, `cuda:all` | `cuda:all`               |
| simplex / trim   | string | `all` or `none`                           | `none`                   |
| simiplex / extra | string | params passed to dorado basecaller        | `""`                     |
| demultiplexing   | bool   | whether to perform demultiplexing         | `True`                   |
| **report**       |        |                                           |                          |
| tools            | array  | list of tools to include in the report    | `["pycoQC", "NanoPlot"]` |
