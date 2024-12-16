# Improved Makefile for RNA-Seq count matrix generation with detailed logging
SHELL = bash
.ONESHELL:
.SHELLFLAGS = -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

# Variables
ACC = GCF_000001215.4
REF_DIR = refs
REF = $(REF_DIR)/fly.fa
GTF = $(REF_DIR)/fly.gtf
DESIGN = design.csv
N = 5000
DATA_DIR = reads
BAM_DIR = bam
RES_DIR = res
COUNTS_TXT = $(RES_DIR)/counts-hisat.txt
COUNTS_CSV = $(RES_DIR)/counts-hisat.csv

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
	@echo "# make clean       # Clean all generated files."
	@echo "# make all         # Run all steps."

# Create the design file
.PHONY: design
design:
	mkdir -p $(dir $(DESIGN))
	bio search PRJNA588978 -H --csv > $(DESIGN)
	@echo "Design file created at $(DESIGN)."

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
	mkdir -p $(DATA_DIR)
	csvcut -c 1 $(DESIGN) | tail -n +2 | head -3 | \
		parallel -j 4 "fastq-dump -X $(N) --outdir $(DATA_DIR) --split-files {} && echo 'Downloaded: {}'"
	@echo "RNA-seq data downloaded to $(DATA_DIR)."

# Align reads with HISAT2
.PHONY: align
align: $(DESIGN) $(REF) $(DATA_DIR)
	mkdir -p $(BAM_DIR)
	csvcut -c 1 $(DESIGN) | tail -n +2 | head -3 | parallel -j 4 \
		'if [[ -f $(DATA_DIR)/{}_1.fastq && -f $(DATA_DIR)/{}_2.fastq ]]; then \
			make -f src/run/hisat2.mk REF=$(REF) R1=$(DATA_DIR)/{}_1.fastq R2=$(DATA_DIR)/{}_2.fastq BAM=$(BAM_DIR)/{}.bam run; \
		else \
			echo "FASTQ files for sample {} are missing. Skipping..."; \
		fi'
	@echo "Alignments completed. BAM files saved in $(BAM_DIR)."

# Generate counts file
$(COUNTS_TXT): $(DESIGN)
	mkdir -p $(RES_DIR)
	@echo "Generating counts file..."
	cat $(DESIGN) | csvcut -c run_accession | tail -n +2 | head -3 > $(RES_DIR)/design_debug.csv
	cat $(RES_DIR)/design_debug.csv | \
		parallel $(PARALLEL_FLAGS) \
			"make -f src/run/hisat2.mk REF='$(REF)' R1='$(DATA_DIR)/{1}_1.fastq' R2='$(DATA_DIR)/{1}_2.fastq' BAM='$(BAM_DIR)/{1}.bam' run || echo 'Error in sample {1}. Skipping...' >> $(RES_DIR)/error.log"
	@echo "Counts file generated at $(COUNTS_TXT)."

# Generate counts-hisat.txt from BAM files
$(COUNTS_TXT): $(DESIGN) $(BAM_DIR) $(GTF)
	mkdir -p $(RES_DIR)
	micromamba run -n stats featureCounts -p -a $(GTF) -o $(COUNTS_TXT) $(BAM_DIR)/*.bam
	@echo "Counts file generated at $(COUNTS_TXT)."

# Generate count matrix in CSV format
$(COUNTS_CSV): $(COUNTS_TXT)
	@echo "Converting counts to CSV format..."
	micromamba run -n stats Rscript src/r/format_featurecounts.r -c $(COUNTS_TXT) -o $(COUNTS_CSV)
	@echo "Count matrix CSV saved at $(COUNTS_CSV)."

# Generate count matrix and list files
.PHONY: count
count: $(COUNTS_CSV)
	@if [[ -f $(COUNTS_TXT) ]]; then \
		echo "$(COUNTS_TXT) found:"; \
		ls -lh $(COUNTS_TXT); \
	else \
		echo "Error: Counts TXT file not found."; \
		exit 1; \
	fi
	@if [[ -f $(COUNTS_CSV) ]]; then \
		echo "$(COUNTS_CSV) found:"; \
		ls -lh $(COUNTS_CSV); \
	else \
		echo "Error: Counts CSV file not found."; \
		exit 1; \
	fi
	@echo "Count matrix files generated successfully."

# Run all steps
.PHONY: all
all: design index data align count
	@echo "All steps completed successfully!"

# Cleanup generated files
.PHONY: clean
clean:
	rm -rf $(REF_DIR) $(DATA_DIR) $(BAM_DIR) $(RES_DIR) ncbi_dataset ncbi_dataset.zip $(DESIGN)
	@echo "Cleaned up all generated files."

# Environment setup check
.PHONY: check_env
check_env:
	micromamba list -n stats || { echo "Micromamba environment not found!"; exit 1; }
