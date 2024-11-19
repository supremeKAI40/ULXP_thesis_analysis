#!/bin/bash

# Define the input file containing the obsID, period, and chi-square values
input_file="experimenting_orbital_correction/all_lc_periods_chisq.txt"  # Replace with your actual file name
base_output="./bootstrap_error"

# Check if the input file exists
if [[ ! -f "$input_file" ]]; then
    echo "Error: Input file $input_file does not exist."
    exit 1
fi

# Create a directory for the output if it doesn't exist

mkdir -p $base_output

# Loop over each line in the input file
# Loop over each line in the input file
while IFS=$'\t' read -r LC_File_Path Period ChiSquare Date; do
    # Skip the header line if it exists
    if [[ "$LC_File_Path" == "LC_File_Path" ]]; then
        continue
    fi

    # Extract obsID from the LC_File_Path
    obsID=$(basename "$LC_File_Path" | cut -d'_' -f1)

    echo "Processing obsID: $obsID with Period: $Period"

    # Define input and output directories based on obsID
    input_dir="./experimenting_orbital_correction/$obsID/xti/event_cl"
    input_lc="$input_dir/ni${obsID}_0mpu7_cl_night_barycorr_orbit.evt"  # Assumes LC_File_Path contains the full file name
    output_dir="$base_output/$obsID"

    # Check if the input directory exists
    if [[ ! -d "$input_dir" ]]; then
        echo "Error: Input directory $input_dir does not exist for obsID $obsID"
        continue  # Skip to the next line in the input file
    fi

    # Check if the input light curve file exists
    if [[ ! -f "$input_lc" ]]; then
        echo "Error: Light curve file $input_lc does not exist."
        continue  # Skip to the next line in the input file
    fi

    if [[ ! -s "$input_lc" ]]; then
        echo "Error: Light curve file $input_lc is empty."
        continue  # Skip to the next line in the input file
    fi

    # Create output directory if it doesn't exist
    mkdir -p "$output_dir"

    # Remove old output files if they exist
    rm -f "$output_dir/t-chi1.qdp"
    rm -f "$output_dir/periods1.dat"
    rm -f "bootstrap.lc"

    # Loop to generate 200 light curves with varying rate and calculate period
    for ((i=1; i<=2; i++)); do
        # Generate a bootstrap light curve by adding random noise to the rate within the error range
        fcalc "$input_lc" bootstrap.lc RATE "RATE+(2.0*random(RATE)-1)*ERROR"

        # Check if the bootstrap light curve was created
        if [[ ! -f bootstrap.lc ]]; then
            echo "Error: bootstrap.lc file not created in iteration $i"
            exit 1
        fi

        # Prepare input file for epoch folding search (efsearch)
        printf "bootstrap.lc\n-\nINDEF\n$Period\n64\nINDEF\n1e-5\n1024\n \nyes\n/null\nwe test_efs\nstat\nq" > efsearch_inp

        efsearch < efsearch_inp > test1.log

        # Check if efsearch produced valid output
        if [[ ! -f test_efs.pco ]]; then
            echo "Error: test_efs.pco file not found in iteration $i"
            exit 1
        fi

        # Extract the best period from the efsearch output
        per=$(awk '{if (NR==5) print $8}' test_efs.pco)

        # Extract the chi-square value from the log file
        chi=$(tail -4 test1.log | head -1 | awk '{print $7}')

        # Save the period and chi-square value to the periods.dat file
        echo "$per $chi" >> "$output_dir/periods1.dat"

        # Print the iteration number, best period, and chi-square value
        echo "$i $per $chi"

        # Cleanup temporary files for this iteration
        rm -f test* *inp bootstrap.lc
    done

    # Calculate the mean and standard deviation of the periods
    mean=$(awk '{sum+=$1} END {print sum/NR}' "$output_dir/periods1.dat")
    stddev=$(awk -v mean=$mean '{sum+=($1-mean)^2} END {print sqrt(sum/NR)}' "$output_dir/periods1.dat")

    # Output the mean period and standard deviation
    echo "Mean period: $mean"
    echo "Standard deviation (error on period): $stddev"

    # Store the mean and standard deviation in the final results file
    echo "Mean period: $mean" >> "$output_dir/t-chi1.qdp"
    echo "Standard deviation (error on period): $stddev" >> "$output_dir/t-chi1.qdp"

done < "$input_file"

# Cleanup any additional files as needed
