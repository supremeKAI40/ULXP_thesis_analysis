#!/bin/bash

# Give ObsIDs and Periods manually
# Define observation information in arrays
obs_ids=("6050390201" "6050390204" "6050390216" "6050390227" "6050390244" "6050390261" "6050390284")
periods=("9.8082" "9.8039" "-none-" "9.7990" "9.8009" "9.7890" "9.7722")
output_phases=("64" "64" "64" "64" "64" "64" "64")  # Change nphase values if needed

# Loop through each observation ID and run efold
for i in "${!obs_ids[@]}"; do
    obs_id=${obs_ids[$i]}
    period=${periods[$i]}

    # Check if period is defined, skip if "-none-"
    if [[ "$period" != "-none-" ]]; then
        # Define input and output file paths
        light_curve_file="${obs_id}/xti/event_cl/ni${obs_id}_cl_night_barycorrmpu7_sr_night.lc"
        output_profile="${obs_id}/xti/event_cl/${obs_id}_pulse_profile.fits"
        nphase=${output_phases[$i]}

        # Run the efold command
        efold 1 "$light_curve_file" outfile="$output_profile" dper="$period" nphase="$nphase" normalization=0
        
        # Print status message
        echo "Processed ObsID $obs_id with period $period"
    else
        echo "Skipping ObsID $obs_id due to missing period"
    fi
done

