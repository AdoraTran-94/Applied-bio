# Data Download and Analysis Documentation of GFF3 file
*Create directory HW2 in the Applied-bio and change it to HW2 directory
    cd ~/Applied-bio
    mkdir HW2
    cd HW2
## 1. Downloading the gff 
* https://ftp.ensembl.org/pub/current_gff3/drosophila_melanogaster/Drosophila_melanogaster.BDGP6.46.112.primary_assembly.mitochondrion_genome.gff3.gz
    
    wget https://ftp.ensembl.org/pub/current_gff3/drosophila_melanogaster/Drosophila_melanogaster.BDGP6.46.112.primary_assembly.mitochondrion_genome.gff3.gz
---
## 2. Uncompressing the File 
* drosophila_melanogaster.BDGP6.46.112.primary_assembly.mitochondrion_genome.gff3.gz’, then change your directory to the working directory where there is the GFF3 file ‘Drosophila_melanogaster.BDGP6.46.112.primary_assembly.mitochondrion_genome.gff3’
### cd /'****your directories'/Drosophila_melanogaster.BDGP6.46.112.primary_assembly.mitochondrion_genome.gff3/
### or Unzip the gff file
    gunzip Drosophila_melanogaster.BDGP6.46.112.primary_assembly.mitochondrion_genome.gff3
---
## 3. Counting the Number of Features
    grep -v "^#" Drosophila_melanogaster.BDGP6.46.112.primary_assembly.mitochondrion_genome.gff3 | wc -l
* grep -v "^#": to search the file. Then with the -v flag, the command will invert the match, it will exclude lines that start (^) with #. In GFF3 files, lines starting with ###are comments or metadata. |: The pipe operator (|) sends the output from grep (the lines that don't start with #) to the next command. Finally, this command will count the number of lines in the output from gret by using wc –l in which the -l flag means "line count."
* or this command
    cat Drosophila_melanogaster.BDGP6.46.112.primary_assembly.mitochondrion_genome.gff3 | cut -f 1 | sort | uniq -c 
---
## 4. Counting the Number of sequence regions (chromosomes) 
    grep "^##sequence-region" Drosophila_melanogaster.BDGP6.46.112.primary_assembly.mitochondrion_genome.gff3 | wc -l
* grep "^##sequence-region" to find lines that start with ##sequence-region, which define the sequence regions (chromosomes). wc –l to count the number of such lines, which corresponds to the number of sequence regions (chromosomes) in the file.
* To print the ##sequence-region line from the file to the screen:
    grep "^##sequence-region" Drosophila_melanogaster.BDGP6.46.112.primary_assembly.mitochondrion_genome.gff3
* grep "^##sequence-region" to find the line that starts with ##sequence-region and print the ##sequence-region line on the screen.
---
## 5. Counting the Number of Genes
    grep -v "^#" Drosophila_melanogaster.BDGP6.46.112.primary_assembly.mitochondrion_genome.gff3 | awk '$3 ~ /gene/' | wc -l
* grep -v "^#" to filter out all comment lines (which start with #). awk '$3 ~ /gene/'to match any line where the feature type contains the word "gene" in the third column. ###Finally, wc -l counts the number of lines that match, which corresponds to the number of genes listed in the file.
---
## 6. Identifying the Top Ten Most Annotated Feature Types
    grep -v "^#" Drosophila_melanogaster.BDGP6.46.112.primary_assembly.mitochondrion_genome.gff3 | awk '{print $3}' | sort | uniq -c | sort -nr | head -n 10
* grep -v "^#" to filter out comment lines (which start with #). awk '{print $3}’ to extract the third column, which contains the feature types. sort to sort the feature types alphabetically. uniq –c to count occurrences of each unique feature type. sort –nr to sort the counts in numerical reverse order (most frequent first). Finally, head -n 10 to display the top ten feature types.

* Here is the link to access the .md file named 'HW2' via https://github.com/AdoraTran-94/Applied-bio

* copy the text file named 'QnA' from desktop into folder HW2 (my current Ubuntu directory)
````
    cp /mnt/c/Users/Hieu/Desktop/QnA.txt /home/adora/Applied-bio/HW2/
    ls /home/adora/Applied-bio/HW2/
````

* Upload this folder HW2 into Git hub
````
    mkdir -p /home/adora/Applied-bio
    cp -r /home/adora/Applied-bio/HW2/ /home/adora/Applied-bio
    git add HW2/
    git commit -m "Created HW2 folder and added files" 
    git push origin main
````
* Update changes for the same folder on Git hub
```cd /home/adora/Applied-bio
```git add .
```git add HW2
```git commit -m "Updated HW2"
```git push origin main

