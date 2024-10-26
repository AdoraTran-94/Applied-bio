# Week 9: Filter a BAM file

This document provides an overview of the Makefile used for downloading a reference genome, simulating reads, trimming and quality-checking reads, aligning those reads to the reference, filtering alignments, and generating alignment statistics.

## Variables
````
SRR: The Sequence Read Archive (SRA) identifier (SRR001666).
ACC: The genome accession number (GCF_000005845.2).
REF: The path to the reference genome file (refs/ecoli.fa).
BAM: The output path for the aligned BAM file (bam/ecoli.bam).
FILTERED_BAM: The output path for the filtered BAM file (bam/ecoli.filtered.bam).
SIMULATED: Directory for simulated reads (/home/adora/Applied-bio/HW8/simulated).
READS_DIR: Directory for downloaded reads (reads).
TRIMMED_DIR: Directory for trimmed reads (trimmed_reads).
ALIGN_STATS: File for storing alignment statistics (alignment_stats.txt).
FILTERED_STATS: File for storing filtered alignment statistics (filtered_alignment_stats.txt).
````

## Targets

### `all`
The default target that runs all necessary steps in sequence:
1. `download`: Downloads the reference genome.
2. `index`: Creates an index for the reference genome.
3. `simulate`: Simulates reads from the reference genome.
4. `trim`: Trims and quality-checks the simulated reads.
5. `fastqc`: Generates quality control reports for the reads.
6. `align`: Aligns the trimmed reads to the reference genome.
7. `stats`: Generates and saves alignment statistics.
8. `alignment_analysis`: Performs specific analyses on the BAM file (e.g., counting unaligned reads).
9. `filter_stats`: Filters the BAM file and compares alignment statistics.

### `download`
Creates the `refs` directory and downloads the genome using the NCBI Datasets command-line tool. It unzips the genome data and moves the FASTA file to the specified reference path.

### `index`
Creates an index for the reference genome using BWA (Burrows-Wheeler Aligner). This is necessary for efficient read alignment.

### `simulate`
Downloads 10,000 reads from the specified SRA identifier using `fastq-dump` and simulates additional reads from the reference genome using `wgsim`. The simulated reads are stored in the specified directory.

### `trim`
Trims the reads using `fastp` and `trimmomatic`, removing low-quality sequences and preparing the reads for alignment. The trimmed reads are stored in the `trimmed_reads` directory.

### `fastqc`
Generates quality control reports for both original and trimmed reads using `FastQC`.

### `align`
Aligns the trimmed reads to the reference genome using BWA MEM. The output is sorted and indexed using Samtools, resulting in a BAM file.

### `stats`
Generates alignment statistics from the BAM file using Samtools and saves them to a text file.

### `alignment_analysis`
Performs additional analyses on the original BAM file:
- **Counts unaligned reads**.
- **Counts primary, secondary, and supplementary alignments**.
- **Counts properly paired alignments on the reverse strand for the first pair**.

### `filter_bam`
Filters the BAM file to include only properly paired primary alignments with a mapping quality of over 10, saving the result as a new BAM file.

### `filter_stats`
Generates alignment statistics for the filtered BAM file and compares them with the original BAM file statistics.

### `clean`
Removes all generated files and directories, including the reference genome, BAM files, simulated reads, trimmed reads, and alignment statistics.

## Usage

To execute the entire workflow, simply run in terminal:
````
make 
````
Alternatively, to run the workflow with custom data (e.g., Escherichia coli), use:
````
make all SRR=SRR001666 ACC=GCF_000005845.2 REF=refs/ecoli.fa BAM=bam/ecoli.bam
````
To clean up the generated files, run:
````
make clean
````
## Results

1. How many reads did not align with the reference genome?
````
@echo "Counting unaligned reads..."
	samtools view -c -f 4 $(BAM)
````
* There was 5178 unaligned reads
2. How many primary, secondary, and supplementary alignments are in the BAM file?
````
	@echo "Counting primary alignments..."
	samtools view -c -F 256 -F 2048 $(BAM)
    @echo "Counting secondary alignments..."
	samtools view -c -f 256 $(BAM)
	@echo "Counting supplementary alignments..."
	samtools view -c -f 2048 $(BAM)
````
* There are 19684 primary, 0 secondary, and 0 supplementary alignments.

3. How many properly-paired alignments on the reverse strand are formed by reads contained in the first pair ?
````
@echo "Counting properly paired alignments on the reverse strand for the first pair..."
	samtools view -c -f 99 $(BAM) # flag 99 indicates proper pair with first read on reverse strand
````
* There are 3414 -paired alignments on the reverse strand are formed by reads contained in the first pair.

5. Compare the flagstats for your original and your filtered BAM file.

Here is the original BAM file statistics.
````
19684 + 0 in total (QC-passed reads + QC-failed reads)
19684 + 0 primary
0 + 0 secondary
0 + 0 supplementary
0 + 0 duplicates
0 + 0 primary duplicates
14506 + 0 mapped (73.69% : N/A)
14506 + 0 primary mapped (73.69% : N/A)
19684 + 0 paired in sequencing
9842 + 0 read1
9842 + 0 read2
13684 + 0 properly paired (69.52% : N/A)
13690 + 0 with itself and mate mapped
816 + 0 singletons (4.15% : N/A)
0 + 0 with mate mapped to a different chr
0 + 0 with mate mapped to a different chr (mapQ>=5)
````
Here is the alignment statistics for the filtered BAM file 
````
filtered_alignment_stats.txt
13496 + 0 in total (QC-passed reads + QC-failed reads)
13496 + 0 primary
0 + 0 secondary
0 + 0 supplementary
0 + 0 duplicates
0 + 0 primary duplicates
13496 + 0 mapped (100.00% : N/A)
13496 + 0 primary mapped (100.00% : N/A)
13496 + 0 paired in sequencing
6748 + 0 read1
6748 + 0 read2
13496 + 0 properly paired (100.00% : N/A)
13496 + 0 with itself and mate mapped
0 + 0 singletons (0.00% : N/A)
0 + 0 with mate mapped to a different chr
0 + 0 with mate mapped to a different chr (mapQ>=5)
````
### The alignment statistics for the filtered BAM file seems to have better compares them with the original BAM file statistics: 
The filtering step appears to have focused on retaining high-quality, properly paired, and mapped reads. This results in a BAM file where:
- All reads are mapped.
- All reads are properly paired.
- Singleton and unpaired reads are removed.
These filtering criteria likely aim to ensure that the remaining reads are reliable for downstream analyses, especially for applications that require high confidence in read pairing and alignment accuracy. The filtered BAM file is more stringent in quality, reducing noise from unmapped, unpaired, or low-quality alignments, which could improve the robustness of any downstream analysis.