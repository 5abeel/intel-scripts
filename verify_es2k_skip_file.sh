#!/bin/bash

# Source the environment file
source ./config.env

# Verify MAC addresses on ACC
printf "Verifying MAC addresses on ACC..."

ssh $SSH_OPTIONS $IMC "ssh $SSH_OPTIONS $ACC '
    CONFIG_FILE=/usr/share/stratum/es2k/es2k_skip_p4.conf
    config_macs=\$(jq -r \".chip_list[0].ctrl_map[] | select(type == \\\"string\\\") | select(test(\\\"^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})\$\\\"))\" \$CONFIG_FILE)
    system_macs=\$(ip -br link | awk \"{print \\\$3}\" | grep -E \"^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}\$\")
    
    all_macs_found=true
    while IFS= read -r mac; do
        if ! echo \"\$system_macs\" | grep -qi \"\$mac\"; then
            all_macs_found=false
            break
        fi
    done <<< \"\$config_macs\"
    
    if \$all_macs_found; then
        exit 0
    else
        exit 1
    fi
'"

if [ $? -eq 0 ]; then
    echo "All MAC addresses verified on ACC!"
    exit 0
else
    echo "Error: Some MAC addresses not found on ACC."
    exit 1
fi
