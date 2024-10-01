#!/bin/bash

## Script to run nicerl3-lc on night observations with different bins
# Array of folders
folders=("6050390201" "6050390204" "6050390216" "6050390227" "6050390244" "6050390261" "6050390284")

# Array of PI ranges
pi_ranges=("80-300" "300-500" "500-800" "800-1200")

# Loop through each folder
for folder in "${folders[@]}"; do
    # Loop through each PI range
    for pi_range in "${pi_ranges[@]}"; do
        # Run the nicerl3-lc command for each folder and PI range
        nicerl3-lc indir="$folder" clfile='$CLDIR/ni$OBSID_0mpu7_cl_night_barycorr.evt' pirange="$pi_range" clobber=yes timebin=0.00025 suffix=_night_${pi_range} 2>&1 | tee "$folder/${folder}_night_lc_${pi_range}.log"
    done
done
