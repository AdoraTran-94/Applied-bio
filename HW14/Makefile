# Makefile for RNA-Seq count matrix generation with detailed logging

# Shell settings
SHELL = bash
.ONESHELL:
.SHELLFLAGS = -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

# Variables
ACC = GCF_000001215.4
REF_DIR = refs
REF = refs/${ACC}.fa
GTF = refs/${ACC}.gtf
DESIGN = design.csv
N = 5000
BAM_DIR = bam
SAMPLE = rep4_L2
BAM = bam/${SAMPLE}.bam
bam = bam/*.bam
COUNTS_TXT = res/counts-hisat.txt
COUNTS_CSV = res/counts-hisat.cvs
SRR = SRR10505619
R1 = reads/read1.fastq
R2 = reads/read2.fastq
DE_RESULTS = $(RES_DIR)/edger.csv


# Flags for GNU Parallel
PARALLEL_FLAGS = --eta --lb --header : --colsep ,

# Default target
.PHONY: usage
usage:
	@echo "# RNA-Seq count matrix generation"
	@echo "# ACC=$(ACC)"
	@echo "# REF=$(REF)"
	@echo "# GTF=$(GTF)"
	@echo "# DESIGN=$(DESIGN)"
	@echo "#"
	@echo "# make design      # Create the design.csv file."
	@echo "# make index       # Download the reference data and generate the HISAT2 index."
	@echo "# make data        # Download sequencing data from the design file."
	@echo "# make align       # Perform alignment with HISAT2."
	@echo "# make count       # Generate the count matrix in CSV format."
	@echo "# make simulate    # Simulate another matrix"           
	@echo "# make evaluate    # Evaluate the differentially expressed genes."
	@echo "# make evaluate    
	@echo "# make clean       # Clean all generated files."
	@echo "# make all         # Run all steps."

# Check if the bio toolbox is installed.
CHECK_FILE = src/run/genbank.mk
${CHECK_FILE}:
	@echo "# Please install toolbox with: bio code"
	@exit 1


# Download the reference data and generate the HISAT2 index
.PHONY: index
index: $(REF) $(GTF)
	make -f src/run/hisat2.mk index REF=$(REF)
	@echo "HISAT2 index generated."

$(REF):
	mkdir -p $(REF_DIR)
	datasets download genome accession $(ACC) --include genome,gtf
	unzip -n ncbi_dataset.zip -d ncbi_dataset
	cp -f ncbi_dataset/ncbi_dataset/data/$(ACC)/*_genomic.fna $@
	@echo "Reference genome downloaded to $(REF)."

$(GTF):
	cp -f ncbi_dataset/ncbi_dataset/data/$(ACC)/genomic.gtf $@
	@echo "Annotation file downloaded to $(GTF)."

# Download sequencing data
.PHONY: data
data: $(DESIGN)
	make -f src/run/sra.mk SRR=${SRR} R1=${R1} N=${N} run
	@echo "RNA-seq data downloaded"

# Align reads with HISAT2
.PHONY: align
align: $(DESIGN) $(REF) $(DATA_DIR)
	mkdir -p $(BAM_DIR)
	make -f src/run/hisat2.mk \
			REF=${REF} R1=${R1} BAM=${BAM} \
			run
	@echo "Alignments completed. BAM files saved in $(BAM_DIR)."


# Generate counts matrix
.PHONY: count
count:
	mkdir -p res
	featureCounts -a ${GTF} -o ${COUNTS_TXT} ${BAM}
	@echo "Running featureCounts on BAM files: $(bam)..."
	micromamba run -n stats featureCounts -a refs/GCF_000001215.4.gtf -o ${COUNTS_TXT} $(bam) || { echo "featureCounts failed"; exit 1; }
	@echo "Counts file generated at res/counts.txt."
	@echo "Converting counts to CSV format..."
	micromamba run -n stats Rscript src/r/format_featurecounts.r -c ${COUNTS_TXT} -o ${COUNTS_CSV} || { echo "Conversion to CSV failed"; exit 1; }
	@echo "Count matrix CSV saved at res/counts.csv."

#Simulate one maxtrix & Perform differential expression analysis
simulate: 
	# generate_counts:
	# Command to create counts-hisat.csv
	# For example, if you need to run featureCounts or a similar command:
	micromamba run -n stats featureCounts -a refs/GCF_000001215.4.gtf -o ${COUNTS_CSV} $(bam)
	@if [ ! -f counts-hisat.csv ]; then \
		echo "Error: counts-hisat.csv not found."; \
		exit 1; \
	fi
	# Continue with simulation commands...
	echo "Running simulation with counts-hisat.csv..."
	# Your simulation commands here


# Evaluate the results
.PHONY: evaluate
evaluate:
	micromamba run -n stats Rscript src/r/evaluate_results.r -a res/counts.csv -c res/counts-hisat.csv -b edger.csv || { echo "Error during evaluation. Check the R script for missing columns."; exit 1; }
	cat edger.csv | cut -f 1 -d , | head -10
	micromamba run -n stats Rscript src/r/plot_pca.r -c edger.csv
	micromamba run -n stats Rscript src/r/plot_heatmap.r -c edger.csv

# Run all steps
.PHONY: all
all: index data align count simulate evaluate
	@echo "All steps completed successfully!"

# Cleanup generated files
.PHONY: clean
clean:
	rm -rf $(REF_DIR) $(DATA_DIR) $(BAM_DIR) $(RES_DIR) design.csv

# Environment setup check
.PHONY: check_env
check_env:
	micromamba list -n stats || { echo "Micromamba environment not found!"; exit 1; }
