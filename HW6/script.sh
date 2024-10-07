# Week 6: # FASTQ Quality Control 

set -uex  # Enable strict error handling and debugging

## DOWNLOAD DATA FROM THE SRA DATABASE
# Define the SRA accession number
ACCESSION="SRR001666"

# Define the output directory
OUTPUT_DIR="./SRA_data"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

cd $OUTPUT_DIR

# Define output file paths
FASTQ_FILE_1="${ACCESSION}_1.fastq"
FASTQ_FILE_2="${ACCESSION}_2.fastq"

# Check if the first FASTQ files exists
if [ -f "$FASTQ_FILE_1" ] && [ -f "$FASTQ_FILE_2" ]; then
    echo "Files $FASTQ_FILE_1 and $FASTQ_FILE_2 already exist, skipping download."
else
    # Download the FASTQ files if they don't exist
    fastq-dump -X 10000 --split-files "$ACCESSION"
fi


# Print completion message
echo "Download of FASTQ files for $ACCESSION completed successfully!"


## EVALUATE THE QUALITY OF THE DOWNLOADED DATA

# Visualizing sequencing data quality
fastqc $FASTQ_FILE_1
fastqc $FASTQ_FILE_2

## IMPROVE THE QUALITY OF THE READS IN THE DATASET OR SEQUENCING QUALITY CONTROL (QC) 
# QC with fastp

# If the data is paired-end
fastp --cut_tail -i $FASTQ_FILE_1 -I $FASTQ_FILE_2 -o ${ACCESSION}_1.trim.fq -O ${ACCESSION}_2.trim.fq

# QC with trimmomatic
trimmomatic PE ${ACCESSION}_1.fastq ${ACCESSION}_2.fastq \
               ${ACCESSION}_1.trim.fq ${ACCESSION}_1.unpaired.fq \
               ${ACCESSION}_2.trim.fq ${ACCESSION}_2.unpaired.fq \
               SLIDINGWINDOW:4:30

# Generate fastqc reports all datasets.
fastqc *.fq

# Completion message
echo "Quality control and trimming completed successfully!"