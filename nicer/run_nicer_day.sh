#!/bin/bash

mkdir -p output
for obsid_base in all_burst_data/[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]; do
  obsid=$(basename "$obsid_base") 

  output_dir="output/$obsid"             # Define the output directory

  mkdir -p "$output_dir"
  if [ ! -f "$output_dir/ni${obsid}.mkf" ]; then
      rm -f $output_dir/ni${obsid}.mkf*
      cp -p $obsid_base/auxil/ni${obsid}.mkf* $output_dir/
      gunzip -f -d $output_dir/ni${obsid}.mkf.gz
  fi

  nicerl2 indir="$obsid_base" clobber=YES \
     cldir="$output_dir" clfile="$output_dir/ni${obsid}_0mpu7_cl_day.evt" threshfilter=DAY \
     mkfile="$output_dir/ni${obsid}.mkf" | tee "$output_dir/nicerl2_run_day.log"
done