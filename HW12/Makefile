#
# Variant calling workflow.
#
# Accession number of the Drosophila meganogaster genome.
ACC=GCF_000001215.4

# The reference file.
REF=refs/fly.fa

# The GFF file.
GFF=refs/fly.gff

# The sequencing read accession number.
SRR=SRR12141220

# The number of reads to get
N=5000

# The sample name (based on bio search).
SAMPLE = SAMN15430431

# The path to read 1
R1=reads/${SAMPLE}_1.fastq

# The path to read 2
R2=reads/${SAMPLE}_2.fastq

# The resulting BAM file.
BAM=bam/${SAMPLE}.bam

# The resulting variant VCF file (compressed!).
VCF=vcf/${SAMPLE}.vcf.gz

# Custom makefile settings.
SHELL = bash
.ONESHELL:
.SHELLFLAGS = -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

# Print the usage of the makefile.
usage:
	@echo "#"
	@echo "# SNP call demonstration"
	@echo "#"
	@echo "# ACC=${ACC}"
	@echo "# SRR=${SRR}"
	@echo "# SAMPLE=${SAMPLE}"
	@echo "# BAM=${BAM}"
	@echo "# VCF=${VCF}"
	@echo "#"
	@echo "# make bam|vcf|all"
	@echo "#"

# Check that the bio toolbox is installed.
CHECK_FILE = src/run/genbank.mk
${CHECK_FILE}:
	@echo "#"
	@echo "# Please install toolbox with: bio code"
	@echo "#"
	@exit 1


# Download the sequence data & Create the BAM alignment file..
bam: ${CHECK_FILE}
	# Get the reference genome and annotations.
	make -f src/run/datasets.mk ACC=${ACC} REF=${REF} GFF=${GFF} run

	# Index the reference genome.
	make -f src/run/bwa.mk REF=${REF} index

	# Download the sequence data.
	make -f src/run/sra.mk SRR=${SRR} R1=${R1} N=${N} run
	if [ -f "${R2}" ]; then \
		make -f src/run/sra.mk SRR=${SRR} R2=${R2} N=${N} run; \
	fi

	# Align the reads to the reference genome.
	if [ -f "${R2}" ]; then \
		make -f src/run/bwa.mk SM=${SAMPLE} REF=${REF} R1=${R1} R2=${R2} BAM=${BAM} run stats; \
	else \
		make -f src/run/bwa.mk SM=${SAMPLE} REF=${REF} R1=${R1} BAM=${BAM} run stats; \
	fi

# Call the SNPs in the resulting BAM file.
vcf:
		make -f src/run/bcftools.mk REF=${REF} BAM=${BAM} VCF=${VCF} run


# Run all the steps.
all: bam vcf

# Remove all the generated files.
clean:
		rm -rf ncbi_dataset/data/${ACC}
		rm -rf ${REF} ${GFF} ${R1} ${R2} ${BAM} ${VCF}

# These targets do not correspond to files.
.PHONY: bam vcf all usage clean
