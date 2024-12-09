# Variables
ACC=GCF_000001215.4
REF=genome/genome.fa
GFF=genome/annotation.gff

# Targets to create required directories and download files.
all: dirs download_genome bam vcf simulate_counts edger evaluate pca heatmap

# Create required directories.
dirs:
	mkdir -p refs reads bam vcf results simulations

# Downloading genome and GTF annotation.
download_genome:
		mkdir -p genome
		wget -O genome/genome.zip "https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_000001215.4/assembly/GCF_000001215.4_Drosophila_melanogaster_genomic.fna.zip"
		wget -O genome/annotation.zip "https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_000001215.4/annotation/GCF_000001215.4_Drosophila_melanogaster_genomic.gff.zip"
		unzip genome/genome.zip -d genome
		unzip genome/annotation.zip -d genome

# Verify that the bio toolbox is installed.
CHECK_FILE=src/run/genbank.mk
$(CHECK_FILE):
		@echo "# Bio toolbox not installed. Please install with: bio code"
		@exit 1

# Generate the BAM file.
bam: dirs $(CHECK_FILE)
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

# Variant calling
variants:
		mkdir -p vcf/
		bcftools mpileup -Ou -f ${REF} ${BAM} | \
		bcftools call -mv -Ov | \
		bcftools norm -f ${REF} -Oz -o ${VCF}
		echo "Variants saved to ${VCF}."

# RNA-Seq count simulations
simulate_counts:
		micromamba run -n stats Rscript src/r/simulate_counts.r
		echo "Checking simulations/ directory contents..."
		ls -lh simulations
		if [[ -f "simulations/counts.csv" && -f "simulations/design.csv" ]]; then \
			echo "Simulation completed. Generated simulations/counts.csv and simulations/design.csv."; \
		else \
			echo "Simulation failed: Expected output files missing."; \
			exit 1; \
		fi

# RNA-Seq differential expression
edger: dirs ${CHECK_FILE} simulate_counts
		# Run the edgeR analysis
		micromamba run -n stats Rscript src/r/edger.r -c simulations/counts.csv -d simulations/design.csv -o results/edger.csv
		echo "Differential expression analysis completed. Results saved to results/edger.csv."

# Evaluate results
evaluate: dirs ${CHECK_FILE} edger
		# Run the evaluation script
		micromamba run -n stats Rscript src/r/evaluate_results.r -a simulations/counts.csv -b results/edger.csv

# Generate PCA plot
pca: dirs ${CHECK_FILE} edger
		# Generate the PCA plot
		micromamba run -n stats Rscript src/r/plot_pca.r -c results/edger.csv

# Generate heatmap
heatmap: dirs ${CHECK_FILE} edger
		# Generate the heatmap
		micromamba run -n stats Rscript src/r/plot_heatmap.r -c results/edger.csv

# Clean up generated files
clean:
	rm -rf genome bam vcf results simulations

# Write the design file
write_design:
	bio search PRJNA588978 -H --csv > design.csv

# Run with parallel
parallelize:
		cat design.csv | head -10 | \
		parallel --dry-run --lb -j 4 --colsep , --header : \
		make all SRR={run_accession} SAMPLE={sample_alias}

run_pipeline:
		cat design.csv | head -25 | \
		parallel --lb -j 4 --colsep , --header : \
		make all SRR={run_accession} SAMPLE={library_name}

# Main target to run all steps
all: dirs download_genome bam vcf simulate_counts edger evaluate pca heatmap
