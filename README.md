This repository contains a SLURM‐wrapped Bash script for programmatically submitting multiple genome FASTA files to the PHASTER API for prophage prediction, polling until completion, and downloading the results.

# Contents

phaster_batch.sh: The main SLURM script that:

Loops through all .fna files in a specified directory

Submits each to the PHASTER API via HTTP POST

Polls the API until each job is marked "Complete"

Downloads the resulting ZIP file for each genome

Cleans up intermediate JSON files

# Requirements

A SLURM‐managed HPC environment (supporting sbatch)

Bash shell

Standard utilities: wget, grep, sleep, basename, mkdir, rm

Network access to https://phastest.ca

# Configuration

Edit the top of phaster_batch.sh to set your directories:

# Directory containing your multi‐contig FASTA files (*.fna)
FASTA_DIR="/path/to/your/FASTAs"

# Directory where JSON responses and ZIP results will be saved
OUTPUT_DIR="/path/to/output/directory"

Usage

Make the script executable:

chmod +x phaster_batch.sh

Submit the job to SLURM:

sbatch phaster_batch.sh

Check SLURM output:

<JOBID>.out for progress logs

<JOBID>.err for any errors

When the script finishes, your OUTPUT_DIR will contain:

<accession>.zip for each genome (the PHASTER analysis results)
