#!/bin/bash

# List of obsIDs (directories containing light curves)
obsIDs=("6050390244")  # You can dynamically update or generate this list

# Loop over each obsID
for obsID in "${obsIDs[@]}"
do
    echo "Processing obsID: $obsID"

    # Define input and output directories based on obsID
    input_lc="./$obsID/xti/event_cl/ni${obsID}_cl_night_barycorrmpu7_sr_night_0.01.lc"
    output_dir="./bootstrap_error/$obsID"

    # Create output directory if it doesn't exist
    mkdir -p "$output_dir"

    # Remove old output files if they exist
    rm -f "$output_dir/t-chi.qdp"
    rm -f "$output_dir/periods.dat"

    # Loop to generate 1000 light curves with varying rate and calculate period
    for ((i=1; i<=100; i++ ))
    do
        # Generate a bootstrap light curve by adding random noise to the rate within the error range
        fcalc "$input_lc" bootstrap.lc RATE "RATE+(2.0*random()-1)*ERROR"

        # Check if the bootstrap light curve was created
        if [[ ! -f bootstrap.lc ]]; then
            echo "Error: bootstrap.lc file not created in iteration $i"
            exit 1
        fi

        # Prepare input file for epoch folding search (efsearch)
        printf "bootstrap.lc\n-\nINDEF\n9.81\n64\nINDEF\n1e-4\n1024\n \nyes\n/null\nwe test_efs\nstat\nq" > efsearch_inp

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
        echo "$per $chi" >> "$output_dir/periods.dat"

        # Print the iteration number, best period, and chi-square value
        echo "$i $per $chi"

        # Cleanup temporary files for this iteration
        rm -f test* *inp bootstrap.lc
    done

    # Calculate the mean and standard deviation of the periods
    mean=$(awk '{sum+=$1} END {print sum/NR}' "$output_dir/periods.dat")
    stddev=$(awk -v mean=$mean '{sum+=($1-mean)^2} END {print sqrt(sum/NR)}' "$output_dir/periods.dat")

    # Output the mean period and standard deviation
    echo "Mean period: $mean"
    echo "Standard deviation (error on period): $stddev"

    # Store the mean and standard deviation in the final results file
    echo "Mean period: $mean" >> "$output_dir/t-chi.qdp"
    echo "Standard deviation (error on period): $stddev" >> "$output_dir/t-chi.qdp"

done

# Cleanup any additional files as needed
#rm -f ./bootstrap_error/$obsID/periods.dat
