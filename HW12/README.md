# Write the design file
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
Then, we process all the samples use makefile.

## Variant Calling Workflow Makefile Documentation

### Description
This Makefile is designed to automate the process of SNP (Single Nucleotide Polymorphism) calling using sequencing data from *Drosophila melanogaster*. It retrieves the reference genome and sequencing reads, aligns the reads to the genome, and calls variants. The pipeline includes the following key steps:

1. **Download the reference genome and annotations** using NCBI Datasets.
2. **Index the reference genome** using BWA.
3. **Download sequencing reads** from the SRA database.
4. **Align sequencing reads** to the reference genome to produce a BAM file.
5. **Call variants** from the BAM file using bcftools.

---

## Makefile Variables

| Variable  | Description                                     | Example Value                      |
|-----------|-------------------------------------------------|------------------------------------|
| `ACC`     | Genome accession number                        | `GCF_000001215.4`                 |
| `REF`     | Path to the reference genome file              | `refs/fly.fa`                     |
| `GFF`     | Path to the genome annotation (GFF file)       | `refs/fly.gff`                    |
| `SRR`     | Sequencing read accession number               | `SRR12141220`                     |
| `N`       | Number of reads to retrieve                    | `5000`                            |
| `SAMPLE`  | Sample name                                    | `SAMN15430431`                    |
| `R1`      | Path to the first read file                    | `reads/SAMN15430431_1.fastq`      |
| `R2`      | Path to the second read file (if paired-end)   | `reads/SAMN15430431_2.fastq`      |
| `BAM`     | Path to the resulting BAM file                 | `bam/SAMN15430431.bam`            |
| `VCF`     | Path to the resulting compressed VCF file      | `vcf/SAMN15430431.vcf.gz`         |

---

## Targets

| Target   | Description                                    |
|----------|------------------------------------------------|
| `usage`  | Print help information about the Makefile.     |
| `bam`    | Generate a BAM file from sequencing reads.     |
| `vcf`    | Call variants from the BAM file.               |
| `all`    | Run the entire workflow (bam + vcf).           |
| `clean`  | Remove all generated files.                    |

---

## Workflow

### Step 1: Download Reference Genome and Annotations
The reference genome and annotations are downloaded using NCBI Datasets CLI. The genome is saved as `refs/fly.fa` and the annotations as `refs/fly.gff`.

### Step 2: Index the Reference Genome
The reference genome is indexed with BWA to prepare for read alignment.

### Step 3: Download Sequencing Reads
Reads are retrieved from the SRA database using the accession number (`SRR`). If paired-end reads exist, both `R1` and `R2` are downloaded.

### Step 4: Align Reads to the Reference Genome
Reads are aligned to the reference genome using BWA. The resulting alignments are sorted and indexed into a BAM file (`bam/SAMN15430431.bam`).

### Step 5: Call Variants
Variants are called from the BAM file using bcftools. The output is stored as a compressed VCF file (`vcf/SAMN15430431.vcf.gz`).

---

## How to Run the Workflow

1. **Check Dependencies**: Ensure the following tools are installed:
   - `datasets`
   - `bwa`
   - `samtools`
   - `bcftools`

2. **Run the Entire Workflow**:
````
   make all
````
## Discussion of the VCF File
- The VCF file generated provides an overview of the genomic variants detected in the sample compared to the reference genome of Drosophila melanogaster. The metadata section confirms the use of the VCFv4.2 standard, with variants called using bcftools mpileup. The reference genome used, refs/fly.fa, includes multiple contigs, such as NC_004354.4, with a length of over 23 million bases, suggesting a comprehensive dataset.
- The header mentions that all variants passed quality filters (FILTER=PASS), implying a robust dataset. Metrics like INFO/AD and FORMAT/DP provide details about allele depth and read depth, which are critical for assessing the reliability of each variant.
- The VCF file also summarizes genetic variants in samples aligned to reference genome NC_004354.4. These include single nucleotide variants (SNVs) and insertions/deletions (INDELs). SNVs, like a C>A mutation at position 202229, dominate the data and reveal genetic differences. INDELs, such as CCTG>C at position 349704, suggest structural changes in the genome. These annotations, supported by metrics like mapping quality (MQ) and allele depths (AD), provide insights into genomic variation and the potential functional impact of these mutations.
