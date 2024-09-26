# Week 5: Simulating FASTQ files 
set -uex  # Enable strict mode for better error handling

# Check if required tools are installed
if ! command -v datasets &> /dev/null; then
    echo "Error: 'datasets' command not found. Please install NCBI Datasets CLI."
    exit 1
fi

if ! command -v wgsim &> /dev/null; then
    echo "Error: 'wgsim' command not found. Please install wgsim."
    exit 1
fi

if ! command -v seqkit &> /dev/null; then
    echo "Error: 'seqkit' command not found. Please install seqkit."
    exit 1
fi

# Step 1: Download the Escherichia coli str. K-12 substr. MG1655 genome
datasets download genome accession GCF_000005845.2

# Step 2: Unpack the data
unzip -o ncbi_dataset.zip  # -o flag to overwrite without prompt

# Step 3: Create a symlink for simpler genome file access
ln -sf ncbi_dataset/data/GCF_000005845.2/GCF_000005845.2_ASM584v2_genomic.fna ecoli.fa

# Step 4: Report the size of the genome file
file_size=$(stat -c %s ecoli.fa)
echo "File Size: $file_size bytes"

# Step 5: Calculate the total genome size (number of bases)
total_size=$(grep -v '^>' ecoli.fa | tr -d '\n' | wc -c)
echo "Total Size of the Genome: $total_size bases"

# Step 6: Count the number of chromosomes
num_chromosomes=$(grep -c '^>' ecoli.fa)
echo "Number of Chromosomes: $num_chromosomes"

# Step 7: Report chromosome name and length
echo "Chromosome Names and Lengths:"
chromosome_name=$(grep '^>' ecoli.fa)
echo "Name: ${chromosome_name#>}, Length: $total_size bases"

# Step 8: Simulate reads with target coverage of 10x using wgsim
GENOME="ecoli.fa"
TARGET_COVERAGE=10  # Set target coverage to 10x
GENOME_SIZE=$total_size  # The genome size already computed
READ_LENGTH=100  # Average read length in base pairs
NUM_READS=$((TARGET_COVERAGE * GENOME_SIZE / READ_LENGTH))  # Number of reads for 10x coverage

# Paths for output read files
R1="reads/wgsim_read1.fq"
R2="reads/wgsim_read2.fq"

# Step 9: Create directory for reads
mkdir -p reads

# Step 10: Generate paired-end reads with wgsim
wgsim -N $NUM_READS -1 $READ_LENGTH -2 $READ_LENGTH -r 0 -R 0 -X 0 $GENOME $R1 $R2

# Step 11: Use seqkit to report statistics on the FASTQ files
seqkit stats $R1 $R2

# Step 12: Report original sizes of the FASTQ files
r1_size_orig=$(stat -c %s "$R1")
r2_size_orig=$(stat -c %s "$R2")
echo "Original Size of Read 1: $r1_size_orig bytes"
echo "Original Size of Read 2: $r2_size_orig bytes"
total_orig_size=$((r1_size_orig + r2_size_orig))
echo "Total Original Size: $total_orig_size bytes"

# Step 13: Compress the FASTQ files
gzip $R1 $R2
r1_compressed="${R1}.gz"
r2_compressed="${R2}.gz"

# Step 14: Report compressed sizes
r1_size_compressed=$(stat -c %s "$r1_compressed")
r2_size_compressed=$(stat -c %s "$r2_compressed")
echo "Compressed Size of Read 1: $r1_size_compressed bytes"
echo "Compressed Size of Read 2: $r2_size_compressed bytes"
total_compressed_size=$((r1_size_compressed + r2_size_compressed))
echo "Total Compressed Size: $total_compressed_size bytes"

# Step 15: Calculate space savings
space_saved=$((total_orig_size - total_compressed_size))
percentage_saved=$(echo "scale=2; $space_saved / $total_orig_size * 100" | bc)
echo "Space Saved: $space_saved bytes, which is $percentage_saved% of the original size"
