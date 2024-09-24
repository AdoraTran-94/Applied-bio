#!/bin/bash

# Set the trace to show the commands as executed
set -uex

# ---- Variable Definitions ----
DATASET_ACCESSION="Bubo"                            # RefSeq accession number for the genome
GFF_FILE_PATH="ncbi_dataset/data/$DATASET_ACCESSION/genomic.gff"  # Path to the GFF file
OUTPUT_FOLDER="/home/adora/Applied-bio/HW4/OUTPUT"              # Output folder for feature results
URL="https://ftp.ensembl.org/pub/current_gff3/bubo_bubo/Bubo_bubo.BubBub1.0.112.gff3.gz"  # Backup URL for GFF file

# ---- NO CHANGES BELOW THIS LINE ----

# Create the necessary directories
echo "Creating directories..."
mkdir -p "$OUTPUT_FOLDER"

# Navigate to the datasets folder and continue
cd /home/adora/Applied-bio/HW4 || exit

# Download genome data using datasets command
echo "Attempting to download genome data for $DATASET_ACCESSION..."
if ! datasets download genome accession $DATASET_ACCESSION --include gff3,rna,cds,protein,genome,seq-report; then
    echo "Dataset download failed for $DATASET_ACCESSION, attempting to download from URL..."
    wget "$URL" -O "$OUTPUT_FOLDER/${DATASET_ACCESSION}.gff3.gz"
    gunzip "$OUTPUT_FOLDER/${DATASET_ACCESSION}.gff3.gz"
    GFF_FILE_PATH="$OUTPUT_FOLDER/${DATASET_ACCESSION}.gff3"
else
    # Unzip the dataset if datasets command succeeds
    echo "Unzipping the dataset..."
    unzip ncbi_dataset.zip
fi

# Check if the GFF file exists
if [[ ! -f "$GFF_FILE_PATH" ]]; then
    echo "GFF file not found!"
    exit 1
fi

# View the content of the dataset
echo "Viewing genome sequence from .fna file..."
cat "ncbi_dataset/data/$DATASET_ACCESSION/${DATASET_ACCESSION}_TS_CPP_V2_genomic.fna" | head || echo "No .fna file found"

# Print the first few lines of the GFF file to inspect the format
echo "Inspecting GFF file format..."
cat "$GFF_FILE_PATH" | head

# Generate unique output filenames based on DATASET_ACCESSION
GENE_OUTPUT="${DATASET_ACCESSION}_gene.gff"                                         # Output file for gene features
CDS_OUTPUT="${DATASET_ACCESSION}_cds.gff"                                           # Output file for CDS features

# Separate "gene" intervals into a different file in OUTPUT directory
echo "Extracting 'gene' features..."
awk '$3=="gene" { print $0 }' "$GFF_FILE_PATH" > "$OUTPUT_FOLDER/$GENE_OUTPUT"

# Separate "CDS" intervals into a different file in OUTPUT directory
echo "Extracting 'CDS' features..."
awk '$3=="CDS" { print $0 }' "$GFF_FILE_PATH" > "$OUTPUT_FOLDER/$CDS_OUTPUT"

# Summary of results
echo "Processed GFF file: $GFF_FILE_PATH"
echo "Gene features saved to: $OUTPUT_FOLDER/$GENE_OUTPUT"
echo "CDS features saved to: $OUTPUT_FOLDER/$CDS_OUTPUT"

# Post-processing or future steps
echo "Process completed successfully."
