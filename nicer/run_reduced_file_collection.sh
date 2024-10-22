#!/bin/bash

# Define the input and output base directories
input_base="output"
output_base="reduced_output"

# Find all obsid directories inside the input_base
obsid_folders=$(find "$input_base" -maxdepth 1 -type d -name "6050*")

# Loop through each obsid folder
for obsid_folder in $obsid_folders; do
    obsid=$(basename "$obsid_folder")
    
    # Define the target output folder for the reduced files
    reduced_obsid_folder="${output_base}/${obsid}"
    
    # Check if the reduced_obsid_folder already exists, and remove it if it does
    if [[ -d "$reduced_obsid_folder" ]]; then
        echo "Folder $reduced_obsid_folder already exists. Deleting it..."
        rm -rf "$reduced_obsid_folder"
    fi
    
    # Create the corresponding folder in reduced_output
    mkdir -p "$reduced_obsid_folder"
    
    # Copy everything except *_ufa.evt files from the obsid folder
    find "$obsid_folder" -type f ! -name "*_ufa.evt" -exec cp {} "$reduced_obsid_folder/" \;
    
    echo "Copied files for $obsid (excluding *_ufa.evt) to $reduced_obsid_folder"
done
