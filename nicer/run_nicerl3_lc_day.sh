#!/bin/bash
## Manually fed array of obsID and run nicerl3-lc with day settings.
# Array of folders
folders=("6050390201" "6050390204" "6050390216" "6050390227" "6050390244" "6050390261" "6050390284")
# Loop through each folder and run the nicerl3-lc command
for folder in "${folders[@]}";
do
    nicerl3-lc indir="$folder" clfile='$CLDIR/ni$OBSID_0mpu7_cl_day_barycorr.evt' threshfilter=DAY chatter=3 pirange=80-1200 clobber=yes timebin=0.00025 suffix=_day 2>&1 | tee "$folder/${folder}_day_lc.log"
done
