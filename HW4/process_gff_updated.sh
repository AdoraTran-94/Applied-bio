#!/bin/bash

# Set the trace to show the commands as executed
set -uex

# ---- Variable Definitions ----
DATASET_ACCESSION="GCF_016801865.2"                            # RefSeq accession number for the genome
GFF_FILE_PATH="ncbi_dataset/data/$DATASET_ACCESSION/genomic.gff"  # Path to the GFF file
OUTPUT_FOLDER1="/home/adora/Applied-bio/HW4/image"             # Output folder for screenshots
OUTPUT_FOLDER2="/home/adora/Applied-bio/HW4/OUTPUT"            # Output folder for feature results

# ---- NO CHANGES BELOW THIS LINE ----

# Create the necessary directories
echo "Creating directories..."
mkdir -p "$OUTPUT_FOLDER1"
mkdir -p "$OUTPUT_FOLDER2"

# Copy screenshots from Windows directory
echo "Copying screenshots..."
cp -r /mnt/c/Users/Hieu/Desktop/image/* "$OUTPUT_FOLDER1/"

# Navigate to the datasets folder and continue
cd /home/adora/Applied-bio/HW4 || exit

# Download genome data
echo "Downloading genome data for $DATASET_ACCESSION..."
datasets download genome accession "$DATASET_ACCESSION" --include gff3,cds,protein,rna,genome

# Unzip the dataset
echo "Unzipping the dataset..."
unzip ncbi_dataset.zip

# View the content of the dataset
echo "Viewing genome sequence from .fna file..."
cat "ncbi_dataset/data/$DATASET_ACCESSION/${DATASET_ACCESSION}_TS_CPP_V2_genomic.fna" | head

# Print the first few lines of the GFF file to inspect the format
echo "Inspecting GFF file format..."
cat "$GFF_FILE_PATH" | head

# Generate unique output filenames based on DATASET_ACCESSION
GENE_OUTPUT="${DATASET_ACCESSION}_gene.gff"                                         # Output file for gene features
CDS_OUTPUT="${DATASET_ACCESSION}_cds.gff"                                           # Output file for CDS features

# Separate "gene" intervals into a different file in OUTPUT directory
echo "Extracting 'gene' features..."
awk '$3=="gene" { print $0 }' "$GFF_FILE_PATH" > "$OUTPUT_FOLDER2/$GENE_OUTPUT"

# Separate "CDS" intervals into a different file in OUTPUT directory
echo "Extracting 'CDS' features..."
awk '$3=="CDS" { print $0 }' "$GFF_FILE_PATH" > "$OUTPUT_FOLDER2/$CDS_OUTPUT"

# Summary of results
echo "Processed GFF file: $GFF_FILE_PATH"
echo "Gene features saved to: $OUTPUT_FOLDER2/$GENE_OUTPUT"
echo "CDS features saved to: $OUTPUT_FOLDER2/$CDS_OUTPUT"

# Post-processing or future steps
echo "Process completed successfully."
