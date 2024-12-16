# Enhanced Makefile for Differential Expression Analysis of RNA-Seq Count Matrix
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
DE_RESULTS = $(RES_DIR)/edger.csv
PCA_PLOT = $(RES_DIR)/pca_plot.png
HEATMAP = $(RES_DIR)/heatmap.png
VOLCANO_PLOT = $(RES_DIR)/volcano_plot.png

# Flags for GNU Parallel
PARALLEL_FLAGS = --eta --lb --header : --colsep ,

# Default target
.PHONY: usage
usage:
	@echo "# RNA-Seq differential expression analysis pipeline"
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
	@echo "# make analyze     # Perform differential expression analysis."
	@echo "# make pca         # Generate PCA plot."
	@echo "# make heatmap     # Generate heatmap of differentially expressed genes."
	@echo "# make volcano     # Generate volcano plot (TODO)."
	@echo "# make all         # Run all steps."
	@echo "# make clean       # Clean all generated files."

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

# Generate count matrix
$(COUNTS_TXT): $(DESIGN) $(BAM_DIR) $(GTF)
	mkdir -p $(RES_DIR)
	micromamba run -n stats featureCounts -p -a $(GTF) -o $(COUNTS_TXT) $(BAM_DIR)/*.bam
	@echo "Counts file generated at $(COUNTS_TXT)."

$(COUNTS_CSV): $(COUNTS_TXT)
	@echo "Converting counts to CSV format..."
	micromamba run -n stats Rscript src/r/format_featurecounts.r -c $(COUNTS_TXT) -o $(COUNTS_CSV)
	@echo "Count matrix CSV saved at $(COUNTS_CSV)."

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

.PHONY: validate_design
validate_design: $(DESIGN)
	@if ! csvcut -n $(DESIGN) | grep -q 'sample'; then \
		echo "Error: 'sample' column not found in $(DESIGN). Please add a 'sample' column."; \
		exit 1; \
	fi

# Perform differential expression analysis
$(DE_RESULTS): $(COUNTS_CSV)
	@echo "Running differential expression analysis..."
	micromamba run -n stats Rscript src/r/edger.r -c $(COUNTS_CSV) -d $(DESIGN) -o $(DE_RESULTS)
	@echo "Differential expression results saved at $(DE_RESULTS)."

.PHONY: analyze
analyze: $(DE_RESULTS)
	@echo "Differential expression analysis completed."

# Generate PCA plot
$(PCA_PLOT): $(DE_RESULTS)
	@echo "Generating PCA plot..."
	micromamba run -n stats Rscript src/r/plot_pca.r -c $(DE_RESULTS) -o $(PCA_PLOT)
	@echo "PCA plot saved at $(PCA_PLOT)."

.PHONY: pca
pca: $(PCA_PLOT)
	@echo "PCA plot generated successfully."

# Generate heatmap
$(HEATMAP): $(DE_RESULTS)
	@echo "Generating heatmap..."
	micromamba run -n stats Rscript src/r/plot_heatmap.r -c $(DE_RESULTS) -o $(HEATMAP)
	@echo "Heatmap saved at $(HEATMAP)."

.PHONY: heatmap
heatmap: $(HEATMAP)
	@echo "Heatmap generated successfully."

# Generate volcano plot (TODO)
.PHONY: volcano
volcano:
	@echo "Generating volcano plot (TODO)."

# Run all steps
.PHONY: all
all: design validate_design index data align count analyze pca heatmap
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