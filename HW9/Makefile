# Variables
SRR = SRR001666
ACC = GCF_000005845.2
REF = refs/ecoli.fa
BAM = bam/ecoli.bam
FILTERED_BAM = bam/ecoli.filtered.bam
SIMULATED = /home/adora/Applied-bio/HW8/simulated
READS_DIR = reads
TRIMMED_DIR = trimmed_reads
ALIGN_STATS = alignment_stats.txt
FILTERED_STATS = filtered_alignment_stats.txt

# Default target
all: download index simulate trim fastqc align stats alignment_analysis filter_stats

# Rule to download the genome
download:
	mkdir -p refs/
	datasets download genome accession $(ACC) --include genome --filename genome.zip
	unzip -o genome.zip -d refs/
	mv refs/ncbi_dataset/data/$(ACC)/*.fna $(REF)

# Rule to create the BWA index for the reference genome
index:
	echo "Creating BWA index for $(REF)..."
	bwa index $(REF)
	echo "BWA index created."

# Rule to simulate reads
simulate:
	mkdir -p $(READS_DIR)
	fastq-dump -X 10000 --split-files --outdir $(READS_DIR) $(SRR)
	echo "Simulating reads for the genome..."
	mkdir -p $(SIMULATED)
	wgsim -N 464165 -e 0.1 $(REF) $(SIMULATED)/read1.fq $(SIMULATED)/read2.fq || { echo "Error occurred"; exit 1; }

# Rule to trim reads using fastp and trimmomatic
.PHONY: trim
trim: download
	@echo "Trimming reads using fastp and trimmomatic..."
	mkdir -p $(TRIMMED_DIR)
	fastp --cut_tail -i $(READS_DIR)/$(SRR)_1.fastq -I $(READS_DIR)/$(SRR)_2.fastq -o $(TRIMMED_DIR)/$(SRR)_1.trim.fq -O $(TRIMMED_DIR)/$(SRR)_2.trim.fq
	trimmomatic PE $(READS_DIR)/$(SRR)_1.fastq $(READS_DIR)/$(SRR)_2.fastq \
		$(TRIMMED_DIR)/$(SRR)_1.trim.fq $(TRIMMED_DIR)/$(SRR)_1.unpaired.fq \
		$(TRIMMED_DIR)/$(SRR)_2.trim.fq $(TRIMMED_DIR)/$(SRR)_2.unpaired.fq \
		SLIDINGWINDOW:4:30
	@echo "Trimming completed."

# Rule to generate FastQC reports
.PHONY: fastqc
fastqc: trim
	@echo "Generating FastQC reports..."
	fastqc $(READS_DIR)/$(SRR)_1.fastq $(READS_DIR)/$(SRR)_2.fastq
	fastqc $(TRIMMED_DIR)/$(SRR)_1.trim.fq $(TRIMMED_DIR)/$(SRR)_2.trim.fq
	@echo "FastQC reports generated."

# Rule to align reads to the reference genome
align:
	mkdir -p bam
	bwa mem $(REF) $(TRIMMED_DIR)/$(SRR)_1.trim.fq $(TRIMMED_DIR)/$(SRR)_2.trim.fq > $(BAM)
	samtools sort -o $(BAM) $(BAM)
	samtools index $(BAM)

# Rule to generate alignment statistics
stats:
	samtools flagstat $(BAM) > $(ALIGN_STATS)
	echo "Alignment statistics saved to $(ALIGN_STATS)."

# Rule for alignment analysis
alignment_analysis:
	@echo "Counting unaligned reads..."
	samtools view -c -f 4 $(BAM)
	@echo "Counting primary alignments..."
	samtools view -c -F 256 -F 2048 $(BAM)
	@echo "Counting secondary alignments..."
	samtools view -c -f 256 $(BAM)
	@echo "Counting supplementary alignments..."
	samtools view -c -f 2048 $(BAM)
	@echo "Counting properly paired alignments on the reverse strand for the first pair..."
	samtools view -c -f 99 $(BAM) # flag 99 indicates proper pair with first read on reverse strand

# Rule to filter BAM file
filter_bam:
	@echo "Filtering BAM file for properly paired primary alignments with mapping quality >10..."
	samtools view -h -q 10 -f 2 -F 256 -o $(FILTERED_BAM) $(BAM)
	samtools index $(FILTERED_BAM)
	@echo "Filtered BAM file created."

# Rule to compare flagstats of original and filtered BAM files
filter_stats: filter_bam
	samtools flagstat $(FILTERED_BAM) > $(FILTERED_STATS)
	@echo "Filtered alignment statistics saved to $(FILTERED_STATS)."
	@echo "Comparison of flagstats completed."

# Clean up generated files
clean:
	rm -rf refs/ bam/ $(READS_DIR) $(SIMULATED) $(TRIMMED_DIR) $(ALIGN_STATS) $(FILTERED_STATS)
