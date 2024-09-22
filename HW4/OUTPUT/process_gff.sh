#!/bin/bash

# Set the trace to show the commands as executed
set -uex

# ---- Variable Definitions ----
feature_type=${1:-"gene"}                                   # Feature type to analyze (default is "gene")
GFF_FILE_PATH="ncbi_dataset/data/GCF_016801865.2/genomic.gff"  # Path to the GFF file
GENE_OUTPUT="gene.gff"                                         # Output file for gene features
CDS_OUTPUT="cds.gff"                                           # Output file for CDS features
DATASET_ACCESSION="GCF_016801865.2"                            # RefSeq accession number for the genome
OUTPUT_FOLDER1="/home/adora/Applied-bio/HW4/image"             # Output folder for screenshots
OUTPUT_FOLDER2="/home/adora/Applied-bio/HW4/OUTPUT"            # Output folder for feature results
ONTOLOGY_OUTPUT="/home/adora/Applied-bio/HW4/Ontology/terms"   # Output folder for ontology results

# ---- NO CHANGES BELOW THIS LINE ----

# Create the necessary directories
echo "Creating directories..."
mkdir -p "$OUTPUT_FOLDER1"
mkdir -p "$OUTPUT_FOLDER2"
mkdir -p "$ONTOLOGY_OUTPUT"

# Copy screenshots from Windows directory
echo "Copying screenshots..."
cp -r /mnt/c/Users/Hieu/Desktop/image/* "$OUTPUT_FOLDER1/"

# Navigate to the datasets folder
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

# Separate "gene" intervals into a different file in OUTPUT directory
echo "Extracting 'gene' features..."
awk '$3=="gene" { print $0 }' "$GFF_FILE_PATH" > "$OUTPUT_FOLDER2/$GENE_OUTPUT"

# Separate "CDS" intervals into a different file in OUTPUT directory
echo "Extracting 'CDS' features..."
awk '$3=="CDS" { print $0 }' "$GFF_FILE_PATH" > "$OUTPUT_FOLDER2/$CDS_OUTPUT"

# Export bio explain output to a file
echo "Exporting bio explanation for feature type '$feature_type'..."
bio explain "$feature_type" > "$ONTOLOGY_OUTPUT/${feature_type}_description.txt"

# Extract parent terms and children nodes from the bio explanation
echo "Extracting parent terms and children nodes for '$feature_type'..."
parent_terms=$(grep -A 20 "Parents:" "$ONTOLOGY_OUTPUT/${feature_type}_description.txt" | grep -v "Children:")
children_nodes=$(grep -A 20 "Children:" "$ONTOLOGY_OUTPUT/${feature_type}_description.txt" | grep -v "Parents:")

# Save parent terms and children nodes separately
echo "Saving parent terms and children nodes..."
echo "$parent_terms" > "$ONTOLOGY_OUTPUT/${feature_type}_parents.txt"
echo "$children_nodes" > "$ONTOLOGY_OUTPUT/${feature_type}_children.txt"

# Summary of results
echo "Processed GFF file: $GFF_FILE_PATH"
echo "Gene features saved to: $OUTPUT_FOLDER2/$GENE_OUTPUT"
echo "CDS features saved to: $OUTPUT_FOLDER2/$CDS_OUTPUT"
echo "Parent terms saved to: $ONTOLOGY_OUTPUT/${feature_type}_parents.txt"
echo "Children nodes saved to: $ONTOLOGY_OUTPUT/${feature_type}_children.txt"

# Post-processing or future steps
echo "Process completed successfully."
