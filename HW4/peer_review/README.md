# I modified the my script 'process_gff_updated.sh' to be able to process the URL link as followed
## 1. Error Handling for Dataset Download: Added a check to attempt a URL download (wget) if the datasets download command fails.
## 2. Backup Download URL: Included a backup URL (ftp link) in case the dataset accession fails.
## 3. File Existence Check: Added logic to verify the GFF file exists before proceeding to further steps.
## 4. File Extraction: If downloaded via the URL, the script will automatically unzip (gunzip) the GFF file.
=======
# I modified the my script 'process_gff_updated.sh' to be able to process the URL link as followed
## 1. Error Handling for Dataset Download: Added a check to attempt a URL download (wget) if the datasets download command fails.
## 2. Backup Download URL: Included a backup URL (ftp link) in case the dataset accession fails.
## 3. File Existence Check: Added logic to verify the GFF file exists before proceeding to further steps.
## 4. File Extraction: If downloaded via the URL, the script will automatically unzip (gunzip) the GFF file.
