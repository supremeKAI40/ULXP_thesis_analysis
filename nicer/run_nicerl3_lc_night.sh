#!/bin/bash
## Script to run nicerl3-lc with default setting of NIGHT. 
# Array of folders
folders=("6050390201" "6050390204" "6050390216" "6050390227" "6050390244" "6050390261" "6050390284")
# Loop through each folder and run the nicerl3-lc command
for folder in "${folders[@]}";
do
    nicerl3-lc indir="$folder" clfile='$CLDIR/ni$OBSID_0mpu7_cl_night_barycorr.evt' pirange=80-1200 clobber=yes timebin=0.0025 suffix=_night 2>&1 | tee "$folder/${folder}_night_lc.log"
done
