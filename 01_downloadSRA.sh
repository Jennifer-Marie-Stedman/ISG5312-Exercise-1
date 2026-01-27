#!/bin/bash
#SBATCH --job-name=fasterq_dump_xanadu
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 12
#SBATCH --mem=15G
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --mail-type=ALL
#SBATCH --mail-user=first.last@uconn.edu
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.err

hostname
date

#################################################################
# Download fastq files from SRA 
#################################################################

# load software
module load parallel/20180122
module load sratoolkit/3.0.1

# Add comment - first edit, master
# Add comment line as part of ISG5312 Exercise 1
# Modified from rnaseq_tutorial on 30Oct2025 by J.Stedmam

# The data are from this study:
    # https://pmc.ncbi.nlm.nih.gov/articles/PMC12380555/#B25 #NK cell transcriptomics pre and post acute exercise/
    # B-ALL remission (experimental group), Age-sex matched healthy (controls)
    # https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE272928
    # https://www.ncbi.nlm.nih.gov/bioproject/PRJNA1139316
     
OUTDIR=/scratch/jstedman/Stedman_Final_Project_FA25/fastq

TMPDIR=/scratch/jstedman/Stedman_Final_Project_FA25/tmpdir
    
METADATA=../../metadata/SraRunTable.txt

mkdir -p $TMPDIR


# Get a list of SRA accession numbers to download, put them in a file.

# There is one experimental group and one control group. Each group contains nine biological replicates.
# Each sample was run across three lanes. Files will be merged downstream using the cat command.

    # The metadata table was downloaded manually to local computer from the SRA's "Run Selector" page, and then transferred to HPC.  

#Pull out the SRA accession number (the first column). Do not include the header.
ACCLIST=../../metadata/accessionlist.txt
cat  $METADATA | cut -f 1 -d ","| grep "SRR*" >$ACCLIST

echo "Accession list has been created."

# use parallel to download 2 accessions at a time. 
cat $ACCLIST | parallel -j 2 "fasterq-dump -O ${OUTDIR} {}"

echo "Accessions have been downloaded."

# compress the files 
ls ${OUTDIR}/*fastq | parallel -j 12 gzip

echo "Files have been compressed."

hostname
date
