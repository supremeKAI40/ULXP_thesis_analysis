#!/bin/bash

# Define the output directory containing obsid folders
output_dir="reduced_output"

# Loop through each obsid folder in the output directory
for obsid_folder in "$output_dir"/6050*/; do
    obsid=$(basename "$obsid_folder")
    
    # Define paths for the day and night barycenter-corrected light curves
    day_barycorr_file="${obsid_folder}/ni${obsid}_cl_day_barycorrmpu7_sr_day.lc"
    night_barycorr_file="${obsid_folder}/ni${obsid}_cl_night_barycorrmpu7_sr_night.lc"
    combined_output_file="${obsid_folder}/ni${obsid}_barycorr_combined.lc"
    log_file="${obsid_folder}/lcmath.lo"

    # Check if both barycenter-corrected files exist
    if [[ -f "$day_barycorr_file" && -f "$night_barycorr_file" ]]; then
        echo "Combining day and night barycorr files for $obsid..."

        # Run lcmath to combine the light curves
        lcmath infile="$day_barycorr_file" \
                bgfile="$night_barycorr_file" \
                outfile="$combined_output_file" \
                addsubr=yes multi=1 multb=1 \
                2>&1 | tee -a "$log_file"

        # Check if the combination was successful
        if [[ $? -eq 0 ]]; then
            echo "Successfully combined barycorr files for $obsid: $combined_output_file"
        else
            echo "Error combining barycorr files for $obsid. Please check the inputs."
        fi
    else
        echo "Missing barycorr files for $obsid. Skipping..."
    fi
done
