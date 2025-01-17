#!/bin/bash

# Source the environment file
source ./config.env

# List of interfaces to check
interfaces=(
    enp0s1f0d1 enp0s1f0d2 enp0s1f0d3 enp0s1f0d4 enp0s1f0d5
    enp0s1f0d6 enp0s1f0d7 enp0s1f0d8 enp0s1f0d9 enp0s1f0d10
    enp0s1f0d11 enp0s1f0d12 enp0s1f0d13 enp0s1f0d14 enp0s1f0d15
)

# Function to check if an interface is up
check_interface() {
    local interface=$1
    ssh $SSH_OPTIONS $IMC "ssh $SSH_OPTIONS $ACC 'ip link show $interface | grep -q \"state UP\"'"
    return $?
}

# Wait for all interfaces to be up
while true; do
    all_up=true
    for interface in "${interfaces[@]}"; do
        if ! check_interface "$interface"; then
            all_up=false
            printf "\nWaiting for $interface to be up on ACC..."
            break
        fi
    done
    if $all_up; then
        printf "\nAll interfaces on ACC are up!\n"
        break
    fi
    sleep 3
done

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
    echo "All MAC addresses verified on ACC to match es2k_skip_p4.conf contents!"
    exit 0
else
    echo "Error: Some MAC addresses not found on ACC."
    exit 1
fi
