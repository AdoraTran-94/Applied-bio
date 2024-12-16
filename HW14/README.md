# Week 14: Perform a differential expression analysis 
## Makefile for RNA-Seq Count Matrix Generation with Detailed Logging
This Makefile automates the process of generating an RNA-Seq count matrix from sequencing data. It integrates various steps including downloading reference data, aligning reads, generating counts, and performing differential expression analysis.

## Shell Settings
- **Shell**: Bash
- **Flags**: 
  - `-eu`: Exit immediately if a command exits with a non-zero status.
  - `-o pipefail`: Return the exit status of the last command in the pipeline that failed.
  - `-c`: Read commands from the command string.

## Variables
- **ACC**: Genome accession number (e.g., `GCF_000001215.4`)
- **REF_DIR**: Directory for reference files.
- **REF**: Path to the reference genome.
- **GTF**: Path to the annotation file.
- **DESIGN**: Design CSV file for sequencing data.
- **N**: Number of reads to process.
- **BAM_DIR**: Directory for BAM files.
- **COUNTS_TXT**: Path to the counts output file in TXT format.
- **COUNTS_CSV**: Path to the counts output file in CSV format.
- **SRR**: Sample accession number (e.g., `SRR10505619`).
- **R1**: Path to the first read FASTQ file.
- **R2**: Path to the second read FASTQ file.
- **DE_RESULTS**: Path for differential expression results.

## Usage
To use this Makefile, run the following commands:

```bash
make usage
```

### Available Targets
- **make design**: Create the `design.csv` file.
- **make index**: Download the reference data and generate the HISAT2 index.
- **make data**: Download sequencing data from the design file.
- **make align**: Perform alignment with HISAT2.
- **make count**: Evaluate the differentially expressed genes.
- **make evaluate**: Generate the count matrix in CSV format.
- **make clean**: Clean all generated files.
- **make all**: Run all steps.

## Target Descriptions

### Check Bio Toolbox Installation
```makefile
CHECK_FILE = src/run/genbank.mk
```
This target checks if the bio toolbox is installed.

### Index Target
```makefile
index: $(REF) $(GTF)
```
Downloads reference data and generates the HISAT2 index.

### Data Target
```makefile
data: $(DESIGN)
```
Downloads sequencing data based on the design file.

### Align Target
```makefile
align: $(DESIGN) $(REF) $(DATA_DIR)
```
Aligns reads using HISAT2 and saves BAM files.

### Count Target
```makefile
count:
	micromamba run -n stats featureCounts -a $(GTF) -o res/counts.txt $(bam)
```
Generates counts matrix from aligned reads.

### Simulate and Differential Expression Analysis
```makefile
simulate: 
```
Runs simulations and performs differential expression analysis.

### Coverage Target
```makefile
coverage:
```
Creates a bigwig coverage track from BAM files.

### Evaluate Results
```makefile
evaluate:
```
Evaluates results and generates plots.

### All Steps Target
```makefile
all: index data align count simulate coverage evaluate
```
Runs all steps in the pipeline.

### Clean Target
```makefile
clean:
```
Cleans up all generated files.

### Environment Setup Check
```makefile
check_env:
```
Checks if the Micromamba environment is set up correctly.

## Conclusion
This Makefile streamlines the RNA-Seq analysis workflow, allowing for efficient processing of sequencing data. Ensure all dependencies are installed and configured before running the commands.

## First, generate the design.csv file
````
bio search PRJNA588978 -H --csv > design.csv
````
## Then run parallel dry run 
````
	cat design.csv | head -10 | \
parallel --dry-run -j 4 --colsep , --header : \
make all SRR={run_accession} SAMPLE={library_name}
````
## Here are outputs:
````
make all SRR=SRR10505617 SAMPLE=rep5_L2
make all SRR=SRR10505618 SAMPLE=rep5_L1
make all SRR=SRR10505621 SAMPLE=rep3_L2
make all SRR=SRR10505619 SAMPLE=rep4_L2
make all SRR=SRR10505622 SAMPLE=rep3_L1
make all SRR=SRR10505626 SAMPLE=rep1_L2
make all SRR=SRR10429163 SAMPLE=rep1_L1
make all SRR=SRR10505616 SAMPLE=rep6_L1
make all SRR=SRR10505620 SAMPLE=rep4_L1
````
## Run all the makefile
````
make all 
````
## Discussion:
1, After the counting:
I got 270 genes with FDR in counts.csv file and 19,732 genes without FDR.
Here are the first 10 genes:
````
name,state,FDR,A1,A2,A3,B1,B2,B3
GENE-127,YES,0,7,7,7,33,18,20
GENE-155,YES,0,68,60,72,59,73,85
GENE-199,YES,0,24,16,30,5,4,3
GENE-333,YES,0,23,21,28,18,39,19
GENE-892,YES,0,429,409,387,92,83,89
GENE-1003,YES,0,416,622,631,834,770,1065
GENE-1017,YES,0,4,11,4,34,58,60
GENE-1059,YES,0,593,415,539,1495,1996,1725
GENE-1077,YES,0,39,25,35,55,54,49
````
2, Im the counts-hisat.csv.summary
Here are the outputs
````
Status	bam/rep1_L1.bam	bam/rep1_L2.bam	bam/rep3_L1.bam	bam/rep3_L2.bam	bam/rep4_L1.bam	bam/rep4_L2.bam	bam/rep5_L1.bam	bam/rep5_L2.bam	bam/rep6_L1.bam
Assigned	2191	2191	2191	2191	2191	2191	2191	2191	2191
Unassigned_Unmapped	2371	2371	2371	2371	2371	2371	2371	2371	2371
Unassigned_Read_Type	0	0	0	0	0	0	0	0	0
Unassigned_Singleton	0	0	0	0	0	0	0	0	0
Unassigned_MappingQuality	0	0	0	0	0	0	0	0	0
Unassigned_Chimera	0	0	0	0	0	0	0	0	0
Unassigned_FragmentLength	0	0	0	0	0	0	0	0	0
Unassigned_Duplicate	0	0	0	0	0	0	0	0	0
Unassigned_MultiMapping	529	529	529	529	529	529	529	529	529
Unassigned_Secondary	0	0	0	0	0	0	0	0	0
Unassigned_NonSplit	0	0	0	0	0	0	0	0	0
Unassigned_NoFeatures	55	55	55	55	55	55	55	55	55
Unassigned_Overlapping_Length	0	0	0	0	0	0	0	0	0
Unassigned_Ambiguity	222	222	222	222	222	222	222	222	222
````
The output summarizes how reads from your RNA-seq data were classified by the featureCounts program.
In short, most reads were successfully assigned to genes, while a smaller number faced issues related to mapping or ambiguity.
1) Assigned:
2191 reads were successfully mapped to features (genes) across all BAM files.
2) Unassigned Reads:
Unmapped: 2371 reads couldn't be mapped to the genome.
Read Type: No reads were excluded due to type issues.
Singletons: No single reads were found without their pair.
Mapping Quality: All reads met the quality threshold.
Chimeric: No chimeric reads were detected.
Fragment Length: No reads were filtered out based on length.
Duplicates: No duplicate reads were identified.
Multi-Mapping: 529 reads mapped to multiple locations.
Secondary: No secondary alignments were present.
Non-Split: No non-split reads were found.
No Features: 55 reads did not match any features.
Ambiguity: 222 reads were ambiguous in their mapping.

3) When I ran the "simulate" command using "Rscript src/r/simulate_counts.r" in stats environment, I got this result:
````
# Initializing  PROPER ... done
# PROspective Power Evaluation for RNAseq 
# Error level: 1 (bottomly)
# All genes: 20000 
# Genes with data: 4665 
# Genes that changed: 1000 
# Changes we can detect: 235 
# Replicates: 3 
# Design: design.csv 
# Counts: counts.csv 
````
For this Evaluation, it indicates that while many genes were assessed, only a small number of changes can be confidently detected.
Initialization: Successfully started the analysis.
Type: PROspective Power Evaluation for RNA-seq.
Error Level: Set at 1 (Bottomly).
Total Genes: 20,000 genes in the dataset.
Genes with Data: Data available for 4,665 genes.
Genes That Changed: 1,000 genes showed changes in expression.
Detectable Changes: Can reliably detect 235 changes.
Replicates: 3 biological replicates were used.
Design File: Referenced in design.csv.
Counts File: Data sourced from counts.csv.

4) I got a bug in the evaluate for Rscript src/r/edger.r and because of that I do not have edger.r to do more analysis. I did try different approaches however, I could not solve this problem. I first tried to run it in my makefile and I did not work and then I tried to run it separately in Terminal 
With the "Rscript src/r/edger.r", I got this error
````
# Initializing edgeR tibble dplyr tools ... done
# Tool: edgeR 
# Design: design.csv 
# Counts: counts-hisat.csv 
# Sample column: sample 
# Factor column: group 
# Factors: A B 
# Group A has 3 samples.
# Group B has 3 samples.
Error in `[.data.frame`(counts_df, , sample_names) : 
  undefined columns selected
Calls: [ -> [.data.frame
Execution halted
````
Without "edgeR.r", I could not make plot and heatmap for this analysis. I will try to find a solution to troubleshoot this problem since I have been working on this makefile for 3 days, I could not finish it better.
````
Rscript  src/r/evaluate_results.r  -a counts.csv -b edger.csv
Error in file(file, "rt") : cannot open the connection
Calls: read.csv -> read.table -> file
In addition: Warning message:
In file(file, "rt") :
  cannot open file 'edger.csv': No such file or directory
Execution halted
````
