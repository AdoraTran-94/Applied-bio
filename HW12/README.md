## Write the design file
````
bio search PRJNA507275 -H --csv > design.csv
````
* The SRR numbers are listed in the run_accession column. The sample names are listed in the sample_alias column. For simplicity, we will use the first ten lines of the design file to test our pipeline, and we first use the --dry-run flag to see what commands will be executed.
````
cat design.csv | head -10 | \
    parallel --dry-run --lb -j 4 --colsep , --header : \
    make all SRR={run_accession} SAMPLE={sample_alias}
````
* If Command 'parallel' not found, but can be installed with:
````
sudo apt install moreutils  # version 0.63-1, or
sudo apt install parallel   # version 20161222-1.1
````
* The output:
````
make all SRR=SRR12123281 SAMPLE=Drosophila\ melanogaster\ red42-Mar-2018
make all SRR=SRR12177581 SAMPLE=Drosophila\ melanogaster\ red42-July-2017
make all SRR=SRR12141220 SAMPLE=Drosophila\ melanogaster\ red42-July-2017
make all SRR=SRR12123280 SAMPLE=Drosophila\ melanogaster\ red42-Mar-2018
make all SRR=SRR12123282 SAMPLE=Drosophila\ melanogaster\ red42-Mar-2018
````
* We notice that the sample names are identical for some SRR numbers. It looks like we have duplicates. The duplication is a bit of conundrum. Running into an unexpected twist is common and we left this note here for that reason.
When you process hundreds of samples, you will encounter various unexpected curveballs. After more investigations, it turns out we should have used the library_name column instead of the sample_alias column. But nobody tells you that in the supporting documentation. You'll have to figure that out yourself. Every experiment has numerous underdocumented quirks so you have to be prepared to troubleshoot.
The beauty of our parallel based approach is that once we identify the solution, we can trivially change the column name that we extract with:
````
cat design.csv | head -10 | \
    parallel --dry-run --lb -j 4 --colsep , --header : \
    make all SRR={run_accession} SAMPLE={library_name}
````
* Here are the outputs:
````
make all SRR=SRR12123281 SAMPLE=63_Red42
make all SRR=SRR12177581 SAMPLE=Red42
make all SRR=SRR12141220 SAMPLE=fast5_pass_red42
make all SRR=SRR12123280 SAMPLE=64_Red42
make all SRR=SRR12123282 SAMPLE=62_Red42
````
Run the pipeline
Remove the --dry-run flag and execute the pipeline.
````
  cat design.csv | head -25 | \
    parallel --lb -j 4 --colsep , --header : \
    make all SRR={run_accession} SAMPLE={library_name}

````

## Merge the vcf files into one:
````
# Merge VCF files into a single one.
bcftools merge -0 vcf/*.vcf.gz -O z > merged.vcf.gz
## Index the merged VCF file
bcftools index merged.vcf.gz
`````

## Install Missing Dependencies: Ensure bedtools, bedGraphToBigWig, and any other missing tools are installed and accessible:
````
sudo apt-get install bedtools
sudo apt-get install ucsc-utilities # For bedGraphToBigWig
````

* 1. Download the UCSC Genome Browser Utilities. You can download the required tool (bedGraphToBigWig) directly from UCSC:
````
# Download the UCSC Genome Browser utilities (64-bit version)
wget http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/bedGraphToBigWig
# Make the tool executable
chmod +x bedGraphToBigWig
# Move it to a directory in your PATH (e.g., /usr/local/bin/)
sudo mv bedGraphToBigWig /usr/local/bin/
````
## The SNP calling Makefile
* We slightly modified the Makefile from the How to call variants chapter to separate the reference download from the variant calling process.
Downloading the reference and indexing it is a one-time operation. We do not need to repeat it for each sample.
* So first we run:
````
make bam
````
Then, we process all the samples.
````
#
# Variant calling workflow.
#

# Accession number of the ebola genome.
ACC=GCA_000848505

# The reference file.
REF=refs/ebola-1976.fa

# The GFF file.
GFF=refs/ebola-1976.gff

# The sequencing read accession number.
SRR=SRR1553425

# The number of reads to get
N=5000

# The name of the sample (see: bio search SRR1553425)
SAMPLE=EM110

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

# Create the BAM alignment file.
bam: ${CHECK_FILE}
    # Get the reference genome and the annotations.
    make -f src/run/datasets.mk ACC=${ACC} REF=${REF} GFF=${GFF} run

    # Index the reference genome.
    make -f src/run/bwa.mk REF=${REF} index

    # Download the sequence data.
    make -f src/run/sra.mk SRR=${SRR} R1=${R1} R2=${R2} N=${N} run

    # Align the reads to the reference genome. 
    # Use a sample name in the readgroup.
    make -f src/run/bwa.mk SM=${SAMPLE} REF=${REF} R1=${R1} R2=${R2} BAM=${BAM} run stats

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
````
# Discussion about the VCF file.

