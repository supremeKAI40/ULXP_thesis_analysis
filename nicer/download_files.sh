#!/bin/bash

# Define the list of URLs to download
urls=(
    "https://heasarc.gsfc.nasa.gov/FTP/nicer/data/obs/2023_06//6050390227/"
    "https://heasarc.gsfc.nasa.gov/FTP/nicer/data/obs/2023_04//6050390204/"
    "https://heasarc.gsfc.nasa.gov/FTP/nicer/data/obs/2023_04//6050390216/"
    "https://heasarc.gsfc.nasa.gov/FTP/nicer/data/obs/2023_09//6050390284/"
    "https://heasarc.gsfc.nasa.gov/FTP/nicer/data/obs/2023_08//6050390261/"
    "https://heasarc.gsfc.nasa.gov/FTP/nicer/data/obs/2023_07//6050390244/"
)

# Loop through each URL and run wget
for url in "${urls[@]}"; do
    wget -q -nH --no-check-certificate --cut-dirs=5 -r -l0 -c -N --show-progress -np -R 'index*' -erobots=off --retr-symlinks "${url}"
done

