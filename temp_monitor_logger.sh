#!/bin/bash

# Default log file path
LOG_FILE="${1:-$HOME/.hardware_temp_log.txt}"

# Ensure jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: 'jq' is not installed. Please install it to run this script."
    exit 1
fi

# Function to fetch and format data
get_stats() {
    local raw_json
    raw_json=$(sensors -j)

    # Use jq to extract specific paths based on your provided JSON structure
    # Note: Using 'to_entries' helps if sensor names change slightly,
    # but here we target your specific keys.
    echo "$raw_json" | jq -r --arg NOW "$(date '+%Y-%m-%d %H:%M:%S')" '
        . as $root |
        [
            $NOW,
            "CPU: \($root."coretemp-isa-0000"."Package id 0".temp1_input)°C",
            "PCH: \($root."pch_cannonlake-virtual-0".temp1.temp1_input)°C",
            "Fan: \($root."asus-isa-0000".cpu_fan.fan1_input) RPM",
            "NVMe: \($root."nvme-pci-0300".Composite.temp1_input)°C"
        ] | join(" | ")
    '
}

# Write header to file if it doesn't exist
if [ ! -f "$LOG_FILE" ]; then
    echo "Timestamp | CPU Temp | PCH Temp | Fan Speed | NVMe Temp" > "$LOG_FILE"
fi

# Execute and output to both stdout and the file
get_stats | tee -a "$LOG_FILE"
