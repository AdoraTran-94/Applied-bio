# Makefile Documentation: Simulating and Processing FASTQ Data
````
This Makefile automates key tasks in bioinformatics workflows, including genome download, read simulation, SRA data download, trimming, and quality control.
````
## Usage: To print the available targets and usage instructions, run:
````
make usage
````
## Makefile Structure
The Makefile is organized into multiple targets. Below is a summary of each target and its function:
| **Target**  | **Description**                                                |
|-------------|----------------------------------------------------------------|
| `usage`     | Prints a list of available targets and how to use them.      |
| `genome`    | Downloads the specified genome using the NCBI Datasets CLI.  |
| `simulate`  | Simulates paired-end reads for the downloaded genome.        |
| `download`  | Downloads reads from the SRA using a specified accession number. |
| `trim`      | Trims the downloaded reads using fastp and trimmomatic.      |
| `fastqc`    | Runs fastqc on FASTQ files to generate quality control reports. |
| `clean`     | Removes generated files and directories to clean up the workspace. |

## Phony Targets
````
use .PHONY to mark targets that don’t generate actual files to prevent make from being confused by similarly named files.
* Example:
.PHONY: genome simulate download trim fastqc clean
````
## Variables in the Makefile
````
* These variables ensure that file paths, genome accessions, and read parameters can be easily configured without changing the underlying logic.
````
| **Target**  | **Description**                                                |
|-------------|----------------------------------------------------------------|
| `usage`     | Print help information about available commands.              |
| `genome`    | Download the genome from NCBI Datasets.                      |
| `simulate`  | Simulate paired-end reads for the downloaded genome.          |
| `download`  | Download FASTQ reads from SRA using the specified accession number. |
| `trim`      | Trim reads using quality control tools.                       |
| `fastqc`    | Generate FASTQC reports for quality assessment of reads.      |
### Variables in the Makefile
* These variables ensure that file paths, genome accessions, and read parameters can be easily configured without changing the underlying logic.

| **Variable** | **Description**                                        | **Default Value**       |
|--------------|--------------------------------------------------------|--------------------------|
| `SRR`        | SRA accession number for downloading reads             | `SRR001666`              |
| `ACC`        | Genome accession number or URL                         | `GCF_000005845.2`        |
| `GENOME`     | Output genome file name                                | `ecoli.fa`               |
| `N`          | Number of reads to simulate                            | `100000`                 |
| `R1`         | Path to the first read file                            | `reads_1.fq`             |
| `R2`         | Path to the second read file                           | `reads_2.fq`             |


* Override these variables on the command line, like this:
````
make simulate N=50000
````
## How to Execute All Commands

* Option 1: Run Targets Individually
````
Download the Genome:
make genome
````
````
Simulate Reads:
make simulate
````
````
Download Reads from SRA:
make download
````
````
Trim the Reads:
make trim
````
````
Generate Quality Control Reports:
make fastqc
````
````
Clean Up Files:
make clean
````

* Option 2: Create an all Target
````
# Add this to your Makefile:
.PHONY: all

all: genome simulate download trim fastqc
    @echo "All tasks completed successfully!"

# @echo pattern helps: Keep the output clean and informative. Focus on the result rather than the underlying commands. Make Makefile's output user-friendly, especially for non-technical users
* Now, you can run everything with a single command:
make all
````

### Explanation of Each Target
````
# Genome Download:
genome:
    datasets download genome accession $(ACC)
    unzip -o ncbi_dataset.zip
    ln -sf ncbi_dataset/data/$(ACC)/*.fna $(GENOME)
## Downloads the genome and creates a symbolic link to simplify access.
````
````
# Simulate Reads:
simulate:
    mkdir -p reads
    wgsim -N $(N) -1 100 -2 100 -r 0 -R 0 -X 0 $(GENOME) $(R1) $(R2)
## Simulates paired-end reads using the genome.
````
````
# Download SRA Reads:

download:
    mkdir -p SRA_data
    fastq-dump -X 10000 --split-files $(SRR) -O SRA_data
## Downloads reads from the SRA database.
````
````
# Trim Reads:
trim:
    fastp -i SRA_data/$(SRR)_1.fastq -I SRA_data/$(SRR)_2.fastq \
          -o trimmed_1.fq -O trimmed_2.fq
    trimmomatic PE trimmed_1.fq trimmed_2.fq \
                trimmed_1.trimmed.fq unpaired_1.fq \
                trimmed_2.trimmed.fq unpaired_2.fq \
                SLIDINGWINDOW:4:30
## Trims reads using fastp and trimmomatic.
````
````
# Generate FastQC Reports:
fastqc:
    fastqc $(R1) $(R2) trimmed_1.fq trimmed_2.fq
## Runs quality control checks on the raw and trimmed reads.
````
````
# Clean Up:
clean:
    rm -rf reads SRA_data trimmed_*.fq *.zip *.fa *.fastq
## Removes all generated files to clean up the workspace.
````

## How to Run the Makefile
* Open your terminal and navigate to the directory containing the Makefile.
Use the following command :
````
# to print usage instructions
    make usage
# to execute individual tasks or run all tasks using:
    make all
````
