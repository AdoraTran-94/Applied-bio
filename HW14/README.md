## Setting up stats environment to run R via RStudio or at the command line. Then I will end up with several environments:
````
•	bioinfo - for bioinformatics tools
•	stats - for statistical analysis
•	salmon_env - for running the salmon aligner
````
### Creating the stats environment We provide a convenient shortcut to bootstrap your stats environment with:
````
# Get the code.
bio code

# Run the script to create the stats environment.
bash src/setup/init-stats.sh 
````
### After completing stats environment, then test.
````
micromamba run -n stats Rscript src/setup/doctor.r
````
•	It should print:
````
# Doctor, Doctor! Give me the R news!
# Checking DESeq2      ... OK
# Checking gplots      ... OK
# Checking biomaRt     ... OK
# Checking tibble      ... OK
# Checking dplyr       ... OK
# Checking tools       ... OK
# You are doing well, Majesty!
````
## Running a single command in stats.
### Run a single command in the stats environment to activates the stats runs a count simulator, then switches back to bioinfo.
````
micromamba run -n stats Rescript src/r/simulate_counts.r
````
### If you plan on running multiple commands in stats it is best if to activate environment explicitly:
````
# Activate stats environments.
micromamba activate stats

# Commands now run in stats.
Rscript src/r/simulate_counts.r
````
•	If I want to see usage information by adding the -h (help) option for each R module.
````
Rscript src/r/simulate_null.r –h
````
•	there is no package called 'edgeR'
### run the doctor to check:
````
src/setup/doctor.r
````
### Usually you can avoid having to switch the entire enviroment by running commands with
````
micromamba run -n stats my_command_here
````
### But if you have to switch environments within a bash shell script then use the following construct:
````
# Turn off error checking and tracing.
set +uex
# Load the micromamba shell initializer.
eval "$(micromamba shell hook --shell bash)"
# Activate the stats environment.
conda activate stats
# This command now runs in stats
echo "Look MA! I am in stats!"
# Activate the bioinfo environment.
conda activate bioinfo
# This command now runs in bioinfo
echo "Look MA! I am in bioinfo!"
# Turn the error checking and tracing back on.
set –uex
````
### Creating a custom environment When you know specifically which tools you wish to run you might want to create a custom environment just for those tools. For example, you want to run the hisat2 based pipeline followed by featurecounts and DESeq2 first create a file called requiments.txt that contains one package per line like so:
````
nano requiments.txt 
````
### Then type the below info., save and exit
````
hisat2 
samtools 
subread 
bioconductor-deseq2 
````
### then you can create your environment with:
````
micromamba create -n rnaseq --file requirements.txt
````
•	But once you have the requirements.txt you can recreate the environment on any other computer, and you can run your pipeline with:
## Activate the environment rnaseq.
````
micromamba run -n rnaseq make -f workflow.mk
````
### In my environment activate bioinfo
````
conda activate bioinfo
````
### If I will use RNA-Seq with salmon, I need to run the toolbox recipe:
````
# Install the toolbox.
bio code

# Run the salmon workflow.
make -f src/recipes/rnaseq-with-salmon.mk 
````
### If I will use RNA-Seq with Hisat2, I need to run the toolbox recipe:
````
# Install the toolbox.
bio code
# Run the hisat2 workflow.
make -f src/recipes/rnaseq-with-hisat.mk
````

# RNA-Seq Count Matrix Generation Workflow

## Overview

This document outlines a Makefile-driven workflow for RNA-Seq data analysis, including alignment, quantification, and generation of a count matrix. The workflow uses HISAT2 for alignment and featureCounts for quantification.

---

## Variables

The following variables are configurable:

| **Variable**       | **Description**                                            | **Default Value**             |
|---------------------|------------------------------------------------------------|--------------------------------|
| `ACC`              | Genome accession number                                    | `GCF_000001215.4`             |
| `REF`              | Path to the reference genome FASTA file                    | `refs/fly.fa`              |
| `GTF`              | Path to the annotation GTF file                            | `refs/fly.gtf`             |
| `DESIGN`           | CSV file listing sequencing runs                           | `design.csv`                  |
| `N`                | Number of reads to download                                | `5000`                        |
| `DATA`             | Directory for sequencing data files                        | `reads/`                      |
| `BAM`              | Path to the BAM file                                       | `bam/${SAMPLE}.bam`           |
| `COUNTS_TXT`       | Path to the featureCounts text output                      | `res/counts-hisat.txt`        |
| `COUNTS_CSV`       | Path to the formatted counts CSV file                      | `res/counts-hisat.csv`        |
| `FLAGS`            | Parallel execution flags                                   | `--eta --lb --header : --colsep ,` |

---

## Usage

Run the following Makefile targets to perform various steps in the workflow:

| **Target**   | **Description**                                                                 |
|--------------|---------------------------------------------------------------------------------|
| `usage`      | Print usage instructions for the workflow.                                      |
| `design`     | Create the `design.csv` file listing sequencing runs.                          |
| `index`      | Download the reference genome and annotations, and create the HISAT2 index.    |
| `data`       | Download sequencing data based on the `design.csv` file.                       |
| `align`      | Perform alignments using HISAT2.                                               |
| `count`      | Generate the count matrix in text and CSV formats.                             |
| `all`        | Execute all steps sequentially.                                                |
| `clean`      | Remove all generated files and directories.                                    |
| `parallel`   | Example for running parallel jobs (dry-run).                                   |

---

## Workflow Steps

### 1. Create the Design File
Generate a CSV file listing sequencing runs based on the specified project accession.
````
bio search PRJNA588978 -H --csv > design.csv
````
### 2. Download and Index the Reference Genome
Download the reference genome and GTF file:
````
datasets download genome accession GCF_000859625.1 --include genome,gtf
unzip -n ncbi_dataset.zip
cp -f ncbi_dataset/data/GCF_000001215.4*/GCF_000001215.4*_genomic.fna refs/fly.fa
cp -f ncbi_dataset/data/GCF_000001215.4*/GCF_000001215.4*/genomic.gtf refs/fly.gtf
Generate the HISAT2 index:
````
make -f src/run/hisat2.mk index REF=refs/rabies.fa
3. Download Sequencing Data
Download sequencing data as specified in the design.csv file:

````
csvcut -c 1 design.csv | tail -n +2 | head -3 | parallel \
    "fastq-dump --temp /path/to/larger/tempdir -X ${N} --outdir reads/ --split-files {}"
````
4. Align Reads
Align the RNA-Seq reads to the reference genome using HISAT2:

````
cat design.csv | head -3 | \
parallel --eta --lb --header : --colsep , \
    "make -f src/run/hisat2.mk \
    REF=refs/rabies.fa \
    R1=reads/{sample}_1.fastq \
    BAM=bam/{sample}.bam \
    run || echo 'Error processing sample: {sample}'"
````
5. Generate Count Matrix
Text Format:
````
featureCounts -a refs/rabies.gtf -o res/counts-hisat.txt bam/{sample}.bam
````
CSV Format:
````
micromamba run -n stats Rscript src/r/format_featurecounts.r -c res/counts-hisat.txt -o res/counts-hisat.csv
````
6. Clean Up
Remove all generated files:

````
rm -rf refs/ reads/ bam/ res/ ncbi_dataset/ ncbi_dataset.zip design.csv
````
Notes
Disk Space: Ensure sufficient disk space for temporary files during download and processing.
Temporary Directory: You can specify a larger temporary directory for fastq-dump using the --temp flag.
Environment Management: Use micromamba for managing dependencies for R scripts and HISAT2 commands.

----
## Discussion: 
Because my disk space is not enough so I still cannot run it successfully and it got stucked at the align. I will update it as soon as possible
