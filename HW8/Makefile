# Variables
SRR = SRR001666
ACC = GCF_000005845.2
REF = refs/ecoli.fa
BAM = bam/ecoli.bam
SIMULATED = /home/adora/Applied-bio/HW8/simulated
READS_DIR = reads
ALIGN_STATS = alignment_stats.txt

# Default target
all: download index simulate align stats

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

# Rule to align reads to the reference genome
align:
	mkdir -p bam
	bwa mem $(REF) $(READS_DIR)/$(SRR)_1.fastq $(READS_DIR)/$(SRR)_2.fastq > $(BAM)
	samtools sort -o $(BAM) $(BAM)
	samtools index $(BAM)

# Rule to generate alignment statistics
stats:
	samtools flagstat $(BAM) > $(ALIGN_STATS)
	echo "Alignment statistics saved to $(ALIGN_STATS)."

# Clean up generated files
clean:
	rm -rf refs/ bam/ $(READS_DIR) $(SIMULATED) $(ALIGN_STATS)

