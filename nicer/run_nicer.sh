#!/bin/bash
## Trial script to do nicerl2 run
mkdir -p  output
$output output
for obsid in [0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]; do
  mkdir -p $output/$obsid/
  if [ ! -f $output/$obsid/ni${obsid}.mkf ]; then
      rm -f $output/$obsid/ni${obsid}.mkf*
      cp -p $obsid/auxil/ni${obsid}.mkf* $output/$obsid/
  fi

  nicerl2 indir=$obsid clobber=YES \
     cldir=$output/$obsid  clfile='$CLDIR/ni$OBSID_0mpu7_cl_night.evt'\
     mkfile='$CLDIR/ni$OBSID.mkf' 
done
