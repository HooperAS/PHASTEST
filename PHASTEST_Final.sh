#!/bin/bash
#SBATCH --partition=epyc_long
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=2GB
#SBATCH --error=%J.err
#SBATCH --output=%J.out

FASTA_DIR="/mnt/scratch45/c1813496/Prophage_Work/FASTAs/FASTAs"
OUTPUT_DIR="/mnt/scratch45/c1813496/Prophage_Work/phastest"
mkdir -p "$OUTPUT_DIR"

# Loop through each .fna file in the directory
for fna_file in "$FASTA_DIR"/*.fna; do
    acc=$(basename "$fna_file" .fna)
    echo "Submitting multi-contig job for: $acc"

    # Submit the file via POST request with contigs=1 using wget
    wget --post-file="$fna_file" --quiet "https://phastest.ca/phastest_api?CONTIGS=1" -O "${OUTPUT_DIR}/${acc}_response.json"

    # Check if the job submission was successful
    job_id=$(grep -oP '"job_id":"\K[^"]+' "${OUTPUT_DIR}/${acc}_response.json")
    status=$(grep -oP '"status":"\K[^"]+' "${OUTPUT_DIR}/${acc}_response.json")

    echo "Job ID: $job_id"
    echo "Status for $acc: $status"

    while [[ "$status" != "Complete" ]]; do
        echo "Job for $acc ($job_id) is not complete. Waiting and retrying..."
        sleep 60
        wget -q "https://phastest.ca/phastest_api?acc=$job_id" -O "${OUTPUT_DIR}/${acc}_response_retry.json"
        status=$(grep -oP '"status":"\K[^"]+' "${OUTPUT_DIR}/${acc}_response_retry.json")
        echo "Status for $acc: $status"
    done

    if [[ "$status" == "Complete" ]]; then
        # Extract the URL for downloading the ZIP file from the completed job response
        zip_url=$(grep -oP '"zip":"\K[^"]+' "${OUTPUT_DIR}/${acc}_response_retry.json")
        echo "Downloading ZIP from: $zip_url"
        wget -q "$zip_url" -O "${OUTPUT_DIR}/${acc}.zip"

    fi

    # Clean up temporary response files to avoid clutter
    rm -f "${OUTPUT_DIR}/${acc}_response.json" "${OUTPUT_DIR}/${acc}_response_retry.json"
done
