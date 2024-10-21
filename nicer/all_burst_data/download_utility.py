def modify_wget_commands(file_path):
    with open(file_path, 'r') as file:
        lines = file.readlines()

    modified_lines = []
    for line in lines:
        if line.startswith("wget"):
            # Add --show-progress flag
            modified_line = line.replace("wget", "wget --show-progress")
            modified_lines.append(modified_line)
        else:
            modified_lines.append(line)

    return modified_lines

def write_modified_commands(output_path, modified_lines):
    with open(output_path, 'w') as file:
        file.writelines(modified_lines)

# Usage
input_file_path = 'nicer/all_burst_data/download_all_data.sh'  # replace with your input file path
output_file_path = 'nicer/all_burst_data/modified_commands.txt'  # replace with your desired output file path

modified_commands = modify_wget_commands(input_file_path)
write_modified_commands(output_file_path, modified_commands)

print("Modified wget commands have been saved to:", output_file_path)