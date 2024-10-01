#!/bin/bash

# Output file to save the paths of .lc files
output_file="lc_file_list.txt"

# Clear the output file if it already exists
> "$output_file"

# Array of folders
folders=("6050390201" "6050390204" "6050390216" "6050390227" "6050390244" "6050390261" "6050390284")

# Loop through each folder and find .lc files with the specified pattern
for folder in "${folders[@]}"; do
    find "$folder/xti/event_cl/" -type f -name "ni${folder}_cl_night_barycorrmpu7_sr_night_*.lc" >> "$output_file"
done

# Notify the user
echo "All .lc files have been saved to $output_file."
