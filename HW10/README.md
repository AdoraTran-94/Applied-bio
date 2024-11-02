# Week 10: Generate a variant call file
This Makefile automates the process of downloading a genome, simulating reads, aligning reads to the reference genome, and calling variants. Below is a detailed explanation of each rule in the Makefile.

## Variables

- **SRR**: The accession number of the SRA data (e.g., `SRR23956858`).
- **ACC**: The genome accession number (e.g., `GCF_000005845.2`).
- **REF**: Path to the reference genome file (e.g., `refs/ecoli.fa`).
- **BAM**: Path to the output BAM file for aligned reads (e.g., `bam/ecoli.bam`).
- **SIMULATED**: Directory for simulated read files (e.g., `/home/adora/Applied-bio/HW8/simulated`).
- **READS_DIR**: Directory for downloaded FASTQ reads (e.g., `reads`).
- **ALIGN_STATS**: Output file for alignment statistics (e.g., `alignment_stats.txt`).
- **VCF**: Path to the output VCF file containing variants (e.g., `variants/ecoli.vcf`).
- **VAR_STATS**: Output file for variant statistics (e.g., `variant_stats.txt`).

## Default Target

The default target for this Makefile is `all`, which includes the following steps:

```makefile
all: download index simulate align stats variants analysis
````
## Rules
1. Download the Genome
This rule downloads the genome using the specified accession number and unzips it.

```
download:
	mkdir -p refs/
	datasets download genome accession $(ACC) --include genome --filename genome.zip
	unzip -o genome.zip -d refs/
	mv refs/ncbi_dataset/data/$(ACC)/*.fna $(REF)
````
2. Create BWA Index
This rule creates a BWA index for the reference genome.

````
index:
	echo "Creating BWA index for $(REF)..."
	bwa index $(REF)
	echo "BWA index created."
````
3. Simulate Reads
This rule simulates reads based on the reference genome.

````
simulate: 
	mkdir -p $(READS_DIR)
	fastq-dump -X 10000 --split-files --outdir $(READS_DIR) $(SRR)
	echo "Simulating reads for the genome..."
	mkdir -p $(SIMULATED)
	wgsim -N 464165 -e 0.1 $(REF) $(SIMULATED)/read1.fq $(SIMULATED)/read2.fq || { echo "Error occurred"; exit 1; }
````
4. Align Reads
This rule aligns the simulated reads to the reference genome and sorts the BAM file.
````
align:
	mkdir -p bam
	@if [ -f "$(READS_DIR)/$(SRR)_2.fastq" ]; then \
		echo "Aligning paired-end reads..."; \
		bwa mem $(REF) $(READS_DIR)/$(SRR)_1.fastq $(READS_DIR)/$(SRR)_2.fastq > $(BAM); \
	else \
		echo "Aligning single-end read..."; \
		bwa mem $(REF) $(READS_DIR)/$(SRR)_1.fastq > $(BAM); \
	fi
	samtools sort -o $(BAM) $(BAM)
	samtools index $(BAM)
````
5. Generate Alignment Statistics
This rule generates statistics about the read alignment.
````
stats:
	samtools flagstat $(BAM) > $(ALIGN_STATS)
	echo "Alignment statistics saved to $(ALIGN_STATS)."
````
6. Call Variants
This rule calls variants from the aligned BAM file and saves the output in a VCF file.
````
variants:
	mkdir -p variants
	bcftools mpileup -Ou -f $(REF) $(BAM) | bcftools call -mv -Ov -o $(VCF)
	echo "Variants saved to $(VCF)."
````
7. Analyze Variant Statistics
This rule analyzes the variants and saves the statistics.
````
analysis:
	bcftools stats $(VCF) > $(VAR_STATS)
	echo "Variant statistics saved to $(VAR_STATS)."
````
8. Clean Up Generated Files
This rule removes all generated files and directories.
````
clean:
	rm -rf refs/ bam/ $(READS_DIR) $(SIMULATED) $(ALIGN_STATS) $(VCF) $(VAR_STATS)
````
Usage
To execute the entire workflow, simply run:
````
make
````
To clean up generated files, run:
````
make clean
````
## Result
* At first, I ran for SRR001666, and I found it is not enough coverage, then I ran for SRR23956858.
* From the variant calls for SRR23956858, I found only SNPs, no indels, and a high ts/tv ratio, reflecting a typical SNP-dominated dataset with no complex variants.
The details are listed below:
### Summary Numbers (SN Section)
* Number of samples: only 1 sample was analyzed in this VCF.
* Number of records: The VCF has 16 records or total variants identified.
* Number of no-ALTs: No records are marked as "no-ALT" (all have alternate alleles).
* Number of SNPs: All 16 records are SNPs, or single-nucleotide polymorphisms.
* Number of MNPs: There are no MNPs (multi-nucleotide polymorphisms, where multiple nucleotides are replaced in one mutation event).
* Number of indels: No insertions or deletions were detected.
* Number of others: No records are classified as "others" (complex substitutions or symbolic alleles).
* Number of multiallelic sites: All sites are biallelic (only one alternate allele per site).
* Number of multiallelic SNP sites: There are no multiallelic SNP sites.
These summary metrics suggest a relatively simple variant profile in the data, with only SNPs and no complex variations like indels or multiallelic sites.
### Transitions/Transversions (TSTV Section)
* ts (transitions): There are 12 transitions, which are mutations between similar types of bases (purines (A↔G) or pyrimidines (C↔T)).
* tv (transversions): There are 4 transversions, which are mutations between purines and pyrimidines (e.g., A↔C or G↔T).
* ts/tv ratio: The ts/tv ratio is 3.00, a value often used to assess the quality of variant calling. Ratios around 2 to 3 are typical, suggesting that the called variants are consistent with known mutation patterns in biological data.
### Singleton Stats (SiS Section)
* Allele count: This section is empty, with no single-allele (singleton) SNPs identified. Singletons are usually rare variants, often seen only once within a dataset.
### Allele Frequency (AF Section)
* Allele frequency: Shows that all 16 SNPs have an allele frequency near 1 (0.99), meaning they appear nearly universally in the sample, suggesting they may be common variants rather than rare mutations.
Quality (QUAL Section)
* Quality scores: Variants are grouped by quality scores, indicating confidence in the variant calls:
* 4.3: 2 SNPs have this lower score.
* 7.3: 14 SNPs have a slightly higher score.
* This distribution indicates moderate confidence in the SNPs, with some lower-quality calls.
Substitution Types (ST Section)
* Substitution counts: Shows the types and counts of base substitutions:
* A>G (4), C>T (4), G>A (2), G>T (2), T>A (1), T>C (2), and A>T (1).
* The variety in substitution types aligns with the observed transitions and transversions in the data.
### Depth Distribution (DP Section)
* Depth distribution: Indicates that all 16 variant sites have data in the "1" depth bin, representing 100% of sites with at least minimal coverage.

### I double check by eyes and the results are correct.