# Improved Makefile for Variant Calling Workflow

# Accession number of the E. coli genome.
ACC=GCF_000005845.2

# The reference file.
REF=refs/ecoli.fa

# The GFF file.
GFF=refs/ecoli.gff

# The sequencing read accession number.
SRR=SRR23956858

# The number of reads to download.
N=5000

# The sample name (based on bio search).
SAMPLE=GSM7115116

# Paths for read 1 and read 2.
R1=reads/${SAMPLE}_1.fastq
R2=reads/${SAMPLE}_2.fastq

# Output paths for BAM and VCF files.
BAM=bam/${SAMPLE}.bam
VCF=vcf/${SAMPLE}.vcf.gz

# Custom makefile settings.
SHELL = bash
.ONESHELL:
.SHELLFLAGS = -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

# Create required directories.
dirs:
	mkdir -p refs reads bam vcf results

# Print usage instructions.
usage:
	@echo "# Variant Calling Workflow"
	@echo "# ACC=${ACC}"
	@echo "# SRR=${SRR}"
	@echo "# SAMPLE=${SAMPLE}"
	@echo "# BAM=${BAM}"
	@echo "# VCF=${VCF}"
	@echo "#"
	@echo "# Usage: make <target>"
	@echo "# Targets: dirs, bam, vcf, all, clean, vep"

# Verify that the bio toolbox is installed.
CHECK_FILE=src/run/genbank.mk
${CHECK_FILE}:
	@echo "# Bio toolbox not installed. Please install with: bio code"
	@exit 1

# Generate the BAM file.
bam: dirs ${CHECK_FILE}
	# Download and prepare reference genome and annotations.
	make -f src/run/datasets.mk ACC=${ACC} REF=${REF} GFF=${GFF} run

	# Index the reference genome.
	make -f src/run/bwa.mk REF=${REF} index

	# Download sequence data.
	make -f src/run/sra.mk SRR=${SRR} R1=${R1} R2=${R2} N=${N} run

	# Align reads and generate BAM file with sample name in read group.
	if [ -s ${R2} ]; then \
		make -f src/run/bwa.mk SM=${SAMPLE} REF=${REF} R1=${R1} R2=${R2} BAM=${BAM} run stats; \
	else \
		make -f src/run/bwa.mk SM=${SAMPLE} REF=${REF} R1=${R1} BAM=${BAM} run stats; \
	fi

# Create the VCF file by calling variants.
vcf: bam
	make -f src/run/bcftools.mk REF=${REF} BAM=${BAM} VCF=${VCF} run

# Full workflow.
all: dirs bam vcf

# Clean up all generated files.
clean:
	rm -rf ncbi_dataset/data/${ACC}
	rm -rf ${REF} ${GFF} ${R1} ${R2} ${BAM} ${VCF}
	rm -rf refs/* reads/* bam/* vcf/* results/*

# These targets do not correspond to actual files.
.PHONY: dirs bam vcf all usage clean

# Prepare sorted and compressed GFF file for VEP.
${GFF}.gz: ${GFF}
	cat ${GFF} | sort -k1,1 -k4,4n -k5,5n -t$'\t' | bgzip -c > ${GFF}.gz
	tabix -p gff ${GFF}.gz

# Run VEP on the VCF file.
vep: ${GFF}.gz
	mkdir -p results
	micromamba run -n vep \
		~/src/ensembl-vep/vep \
		-i ${VCF} \
		-o results/vep.txt \
		--gff ${GFF}.gz \
		--fasta ${REF} \
		--force_overwrite

	# Display output files.
	ls -lh results/*
