Setting up stats environment to run R via RStudio or at the command line. 
Then I will end up with several environments:
````
•	bioinfo - for bioinformatics tools
•	stats - for statistical analysis
•	salmon_env - for running the salmon aligner
````
Creating the stats environment
We provide a convenient shortcut to bootstrap your stats environment with:
````
# Get the code.
bio code

# Run the script to create the stats environment.
bash src/setup/init-stats.sh 
````
After completing stats environment, then test.
````
micromamba run -n stats Rscript src/setup/doctor.r
`````
It should print:
````
# Doctor, Doctor! Give me the R news!
# Checking DESeq2      ... OK
# Checking gplots      ... OK
# Checking biomaRt     ... OK
# Checking tibble      ... OK
# Checking dplyr       ... OK
# Checking tools       ... OK
# You are doing well, Majesty!
````
Running a single command in stats. 
````
# Run a single command in the stats environment to activates the stats runs a count simulator, then switches back to bioinfo.
micromamba run -n stats Rescript src/r/simulate_counts.r
````
If you plan on running multiple commands in stats it is best if to activate environment explicitly:
````
# Activate stats environments.
micromamba activate stats

# Commands now run in stats.
Rscript src/r/simulate_counts.r
````
If I want to see usage information by adding the -h (help) option for each R module.
````
Rscript src/r/simulate_null.r -h
````
#  there is no package called 'edgeR'
run the doctor to check:
````
src/setup/doctor.r
````
Usually you can avoid having to switch the entire enviroment by running commands with
````
micromamba run -n stats my_command_here
````
But if you have to switch environments within a bash shell script then use the following construct:
````
# Turn off error checking and tracing.
set +uex
# Load the micromamba shell initializer.
eval "$(micromamba shell hook --shell bash)"
# Activate the stats environment.
conda activate stats
# This command now runs in stats
echo "Look MA! I am in stats!"
# Activate the bioinfo environment.
conda activate bioinfo
# This command now runs in bioinfo
echo "Look MA! I am in bioinfo!"
# Turn the error checking and tracing back on.
set -uex
````
Creating a custom environment
When you know specifically which tools you wish to run you might want to create a custom environment just for those tools.
For example, you want to run the hisat2 based pipeline followed by featurecounts and DESeq2 first create a file called requiments.txt that contains one package per line like so:
````
nano requiments.txt 
````
Then type the below info., save and exit
````
hisat2 
samtools 
subread 
bioconductor-deseq2 
````
then you can create your environment with:
````
micromamba create -n rnaseq --file requirements.txt
````
But once you have the requirements.txt you can recreate the environment on any other computer, and you can run your pipeline with:
# Activate the environment.
micromamba run -n rnaseq make -f workflow.mk

In my environment activate bioinfo 
````
conda activate bioinfo
````
If I will use RNA-Seq with salmon, I need to run the toolbox recipe:
````
# Install the toolbox.
bio code

# Run the salmon workflow.
make -f src/recipes/rnaseq-with-salmon.mk 
````
•	If I will use RNA-Seq with Hisat2, I need to run the toolbox recipe:
````
# Install the toolbox.
bio code
# Run the hisat2 workflow.
make -f src/recipes/rnaseq-with-hisat.mk
````
Explanation
1.	Variables (ACC, REF, GFF): These variables are defined at the start of the Makefile. They are used throughout the Makefile to specify paths and settings.
2.	download_genome: This target downloads and unzips the genome and annotation files.
3.	bam: Generates the BAM file using bwa, integrating the defined variables.
4.	variants: Calls variants using bcftools and saves the VCF files.
5.	simulate_counts: Runs count simulations using R in a micromamba environment.
6.	edger: Performs differential expression analysis using edgeR on the simulated counts.
7.	evaluate: Evaluates the differential expression results.
8.	pca: Generates a PCA plot from the results.
9.	heatmap: Generates a heatmap from the results.
10.	clean: Cleans up the generated files.
11.	write_design: Creates a design file from a specific PRJNA accession.
12.	parallelize: Runs parallel processing on the design file using make.
13.	run_pipeline: Executes the complete pipeline with parallel processing.
This Makefile should help you automate your RNA-Seq analysis workflow effectively.

