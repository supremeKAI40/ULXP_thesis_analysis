#!/bin/bash

# Base directory
BASE_DIR="."

# Function to check if a file exists
file_exists() {
    local file=$1
    if [ -f "$file" ]; then
        return 0  # File exists
    else
        return 1  # File does not exist
    fi
}

# Function to run a command and log the output
run_command() {
    local cmd=$1
    local log_file=$2
    echo "Running: $cmd" | tee -a "$log_file"
    eval "$cmd" 2>&1 | tee -a "$log_file"
}

process_exposure_lc() {
    local obs_dir=$1
    local input_lc=$2
    local exposure_type=$3  # HE, ME, or LE

    echo "Processing $exposure_type exposure: $input_lc"

    # Define output directory
    local output_dir="$obs_dir/bootstrap_output/$exposure_type"
    mkdir -p "$output_dir"

    # Remove old output files
    rm -f "$output_dir/t-chi1.qdp"
    rm -f "$output_dir/periods1.dat"
    rm -f "$output_dir/bootstrap.lc"

    # Generate 200 bootstrap light curves and calculate periods
    for ((i=1; i<=3; i++ )); do
        echo "Running fcalc on $input_lc for iteration $i"
        fcalc "$input_lc" "$output_dir/bootstrap.lc" RATE "RATE+(2.0*random(RATE)-1)*ERROR"

        if [[ ! -f "$output_dir/bootstrap.lc" ]]; then
            echo "Error: bootstrap.lc file not created in iteration $i. Exiting."
            exit 1
        fi

        # Prepare efsearch input
        printf "$output_dir/bootstrap.lc\n-\nINDEF\n9.80\n64\nINDEF\n1e-4\n1024\n \nyes\n/null\nwe $output_dir/test_efs\nstat\nq" > $output_dir/efsearch_inp
        efsearch < $output_dir/efsearch_inp > $output_dir/test1.log

        if [[ ! -f test_efs.pco ]]; then
            echo "Error: test_efs.pco file not found in iteration $i"
            exit 1
        fi

        # Extract period and chi-square values
        per=$(awk '{if (NR==5) print $8}' $output_dir/test_efs.pco)
        chi=$(tail -4 $output_dir/test1.log | head -1 | awk '{print $7}')

        # Store period and chi-square in output file
        echo "$per $chi" >> "$output_dir/periods1.dat"
        echo "$i $per $chi"

        # Cleanup temporary files
        rm -f $output_dir/test* $output_dir/*inp $output_dir/bootstrap.lc
    done

    # Calculate mean and standard deviation of periods
    mean=$(awk '{sum+=$1} END {print sum/NR}' "$output_dir/periods1.dat")
    stddev=$(awk -v mean=$mean '{sum+=($1-mean)^2} END {print sqrt(sum/NR)}' "$output_dir/periods1.dat")

    # Output results
    echo "Mean period for $exposure_type: $mean"
    echo "Standard deviation (error on period) for $exposure_type: $stddev"

    # Save results to file
    echo "Mean period: $mean" >> "$output_dir/t-chi1.qdp"
    echo "Standard deviation (error on period): $stddev" >> "$output_dir/t-chi1.qdp"
}



process_observation() {
    local obs_dir=$1

    # Navigate to pipeline_output folder
    local pipeline_dir="$obs_dir/pipeline_output"
    
    # Find HE, ME, and LE exposure files
    local he_exposure=$(find "$pipeline_dir" -type f -name "*HE_lcnet*.lc" | head -n 1)
    local me_exposure=$(find "$pipeline_dir" -type f -name "*ME_lcnet*.lc" | head -n 1)
    local le_exposure=$(find "$pipeline_dir" -type f -name "*LE_lcnet*.lc" | head -n 1)

    # Process each exposure if found
    [ -n "$he_exposure" ] && process_exposure_lc "$obs_dir" "$he_exposure" "HE"
    [ -n "$me_exposure" ] && process_exposure_lc "$obs_dir" "$me_exposure" "ME"
    [ -n "$le_exposure" ] && process_exposure_lc "$obs_dir" "$le_exposure" "LE"

    echo $he_exposure 
    echo $me_exposure 
    echo $le_exposure
}


# Function to process each proposal
process_proposal() {
    local proposal=$1

    for obs_dir in "$proposal"/*; do
        if [ -d "$obs_dir" ]; then
            process_observation "$obs_dir"
        fi
    done
}

# Main execution
main() {
    for proposal in "$BASE_DIR"/P*; do
        if [ -d "$proposal" ]; then
            process_proposal "$proposal"
        fi
    done
}

# Run the main function
main
