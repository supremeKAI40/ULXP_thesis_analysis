# #!/bin/bash

# # File to store the consolidated results for all light curves
# consolidated_file="all_lc_periods_chisq.txt"

# # Create or clear the consolidated file
# echo -e "LC_File_Path\tPeriod\tChi-square" > "$consolidated_file"

# # Loop over all obsIDs in the "output" directory
# obsid_folders=$(find ./reduced_output -maxdepth 1 -type d -name "6050*")

# # Loop through each obsid folder
# for obsid_folder in $obsid_folders; do
#     obsid=$(basename "$obsid_folder")
#     echo "Processing obsID: $obsid"

#     # Define the light curve file path (adjust the pattern as necessary)
#     lc_files=$(find "$obsid_folder" -name "*.lc")

#     # Check if any light curve files were found
#     if [[ -z "$lc_files" ]]; then
#         echo "No light curve files found for obsID: $obsid"
#         continue  # Skip to next obsID
#     fi

#     # Loop through each light curve file
#     for lc_file in $lc_files; do
#         echo "Processing light curve: $lc_file"

#         # Define output filenames for efsearch results
#         lc_folder=$(dirname "$lc_file")  # Get the folder where the .lc file is located
#         lc_basename=$(basename "$lc_file" .lc)
#         fes_file="$lc_folder/efsearch.pco"
#         log_file="$lc_folder/${lc_basename}_efsearch.log"

#         # Run efsearch on the light curve file
#         printf "$lc_file\n-\nINDEF\n9.81\n64\nINDEF\n1e-5\n1024\n \nyes \n/null\nwe $fes_file\nstat\nq" > efsearch_inp
#         efsearch < efsearch_inp > $log_file
#         # Check if efsearch produced the .fes file
#         if [[ -f "$fes_file" ]]; then
#             echo "efsearch completed for $lc_file"

#             # # Extract the best period from the .fes file
#             # best_period=$(awk '{if (NR==5) print $8}' "$fes_file")
#             # # Extract the chi-square value from the log file (adjust as needed for your format)
#             # chi_square=$(tail -5 "$log_file" | head -1 | awk '{print $5}')

#             # Extract the best period from the log file (after 'Period :')
#             best_period=$(grep "Period :" "$log_file" | awk '{print $3}')
#             # Extract the chi-square value from the log file (after 'Chisq')
#             chi_square=$(grep "Chisq" "$log_file" | awk '{print $5}')

#             # Append the results to the consolidated file
#             echo -e "$lc_basename\t$best_period\t$chi_square" >> "$consolidated_file"
#             echo "Saved period and chi-square to consolidated file: $consolidated_file"
#         else
#             echo "Error: efsearch failed for $lc_file"
#         fi
#     done
# done

# echo "All periods and chi-squares saved to $consolidated_file"


#!/bin/bash

# File to store the consolidated results for all light curves
consolidated_file="experiment_orbital/all_lc_periods_chisq_sh.txt"

# Create or clear the consolidated file
echo -e "LC_File_Path\tPeriod\tChi-square\tDate" > "$consolidated_file"

# Loop over all obsIDs in the "output" directory
obsid_folders=$(find ./experiment_orbital -maxdepth 1 -type d -name "6050*")

# Loop through each obsid folder
for obsid_folder in $obsid_folders; do
    obsid=$(basename "$obsid_folder")
    echo "Processing obsID: $obsid"

    # Define the light curve file path (adjust the pattern as necessary)
    lc_files=$(find "$obsid_folder" -name "*barycorr_orbit.evt")

    # Check if any light curve files were found
    if [[ -z "$lc_files" ]]; then
        echo "No light curve files found for obsID: $obsid"
        continue  # Skip to next obsID
    fi

    # Loop through each light curve file
    for lc_file in $lc_files; do
        echo "Processing light curve: $lc_file"

        # Define output filenames for efsearch results
        lc_folder=$(dirname "$lc_file")  # Get the folder where the .lc file is located
        lc_basename=$(basename "$lc_file" .lc)
        fes_file="$lc_folder/efsearch.pco"
        log_file="$lc_folder/${lc_basename}_efsearch.log"

        # Run efsearch on the light curve file
        printf "$lc_file\n-\nINDEF\n9.8\n64\nINDEF\n1e-4\n1024\n \nyes \n/null\nwe $fes_file\nstat\nq" > efsearch_inp
        efsearch < efsearch_inp > $log_file
        # Check if efsearch produced the .fes file
        if [[ -f "$fes_file" ]]; then
            echo "efsearch completed for $lc_file"

            # Extract the best period from the log file (after 'Period :')
            best_period=$(grep "Period :" "$log_file" | awk '{print $3}')
            # Extract the chi-square value from the log file (after 'Chisq')
            chi_square=$(grep "Chisq " "$log_file" | awk '{print $5}' | sed 's/^[ \t]*//;s/[ \t]*$//')
            # Extract the Date
            date=$(grep "Start Time " "$log_file" | awk '{print $8}')
            # Check if both values are non-empty
            if [[ -n "$best_period" && -n "$chi_square" ]]; then
                # Append the results to the consolidated file

                echo -e "$obsid\t$best_period\t$chi_square\t$date" >> "$consolidated_file"
                echo "Saved period and chi-square to consolidated file: $consolidated_file"
            else
                echo "Warning: Best period or chi-square is empty for $lc_basename"
            fi
        else
            echo "Error: efsearch failed for $lc_file"
        fi
    done
done

echo "All periods and chi-squares saved to $consolidated_file"
