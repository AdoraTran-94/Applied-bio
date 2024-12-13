# Custom makefile settings.
SHELL = bash
.ONESHELL:
.SHELLFLAGS = -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

# Variables
ACC=GCF_000859625.1
REF=refs/rabies.fa
GTF=refs/rabies.gtf
DESIGN=design.csv
N=5000
DATA=reads/
BAM=bam/${SAMPLE}.bam
COUNTS_TXT=res/counts-hisat.txt
COUNTS_CSV=res/counts-hisat.csv
FLAGS=--eta --lb --header : --colsep ,

# Default target
usage:
	@echo "#"
	@echo "# RNA-Seq count matrix generation"
	@echo "#"
	@echo "# ACC=${ACC}"
	@echo "# REF=${REF}"
	@echo "# GTF=${GTF}"
	@echo "# DESIGN=${DESIGN}"
	@echo "#"
	@echo "# make design      # create the design.csv file."
	@echo "# make index       # download the reference data and generate the HISAT2 index."
	@echo "# make data        # download the sequencing data from design file."
	@echo "# make align       # run the alignment with SRA from design file by HISAT2."
	@echo "# make count       # generate the count matrix in CSV format."
	@echo "# make clean       # clean all files after every run."
	@echo "# make all         # proceed all the targets."
	@echo "#"

# Create the design file
design:
	bio search PRJNA588978 -H --csv > ${DESIGN}
	@echo "Design file created."

# Download the reference data and generate the HISAT2 index
index:
	mkdir -p $(dir ${REF})
	datasets download genome accession ${ACC} --include genome,gtf
	unzip -n ncbi_dataset.zip -x README.md md5sum.txt
	cp -f ncbi_dataset/data/${ACC}*/${ACC}*_genomic.fna ${REF}
	cp -f ncbi_dataset/data/${ACC}*/genomic.gtf ${GTF}
	make -f src/run/hisat2.mk index REF=${REF}
	@echo "Genome is indexed. Thank you!"

# Download the sequencing data from design file
data: ${DESIGN}
	mkdir -p $(dir ${DATA})
	csvcut -c 1 ${DESIGN} | tail -n +2 | head -3 | parallel \
		"fastq-dump --temp /path/to/larger/tempdir -X ${N} --outdir ${DATA} --split-files {} && \
		echo 'Downloaded: {}'"
	@echo "All RNA-seq data are downloaded. Thank you!"


# Run the alignment with SRA from design file by HISAT2
align: ${DESIGN}
	cat ${DESIGN} | head -3 | \
	parallel --eta --lb --header : --colsep , \
		"make -f src/run/hisat2.mk \
		REF=${REF} \
		R1=reads/{sample}_1.fastq \
		BAM=bam/{sample}.bam \
		run || echo 'Error processing sample: {sample}'"
	@echo "The alignment is completed. Thank you!"


# The counts file
${COUNTS_TXT}:
	mkdir -p $(dir $@)
	cat ${DESIGN} | head -3 | \
		parallel --header : --colsep , -k echo bam/{sample}.bam | \
		parallel -u --xargs featureCounts -a ${GTF} -o ${COUNTS_TXT} {}

# Generate the count matrix in CSV format
${COUNTS_CSV}: ${COUNTS_TXT}
	micromamba run -n stats Rscript src/r/format_featurecounts.r -c ${COUNTS_TXT} -o ${COUNTS_CSV}

# List all count files
count: ${COUNTS_CSV}
	@ls -lh ${COUNTS_TXT}
	@ls -lh ${COUNTS_CSV}
	@echo "The count matrix files are generated. Thank you!"

# Run all the steps
all: design index data align count
	@echo "The progress is completed. Thank you!"

# Remove all the generated files
clean:
	rm -rf refs/ reads/ bam/ res/ ncbi_dataset/ ncbi_dataset.zip design.csv

# Example for running parallel jobs
parallel:
	cat ${DESIGN} | head -3 | \
		parallel --dry-run --lb -j 4 ${FLAGS} \
		make all SRR={run_accession} SAMPLE={library_name}
	@echo "Parallel job dry-run completed. Remove --dry-run to execute."

.PHONY: usage design index data align count clean all parallel
