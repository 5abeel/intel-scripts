#!/bin/bash

# Source the environment file
source ./config.env

# List of interfaces to check
interfaces=(
    enp0s1f0d1 enp0s1f0d2 enp0s1f0d3 enp0s1f0d4 enp0s1f0d5
    enp0s1f0d6 enp0s1f0d7 enp0s1f0d8 enp0s1f0d9 enp0s1f0d10
    enp0s1f0d11 enp0s1f0d12 enp0s1f0d13 enp0s1f0d14 enp0s1f0d15
)

# Interfaces whose MAC addresses we need
target_interfaces=(enp0s1f0d4 enp0s1f0d5 enp0s1f0d6 enp0s1f0d7)

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
            printf "\nWaiting for $interface to come up on ACC..."
            break
        fi
    done
    if $all_up; then
        printf "\nAll interfaces on ACC are up!\n"
        break
    fi
    sleep 3
done

# Get MAC addresses for the target interfaces and update the config file
printf "Updating es2k_skip_p4.conf file with this ACC's MAC addresses...\n"

ssh $SSH_OPTIONS $IMC "ssh $SSH_OPTIONS $ACC '
    CONFIG_FILE=/usr/share/stratum/es2k/es2k_skip_p4.conf
    
    # Get MAC addresses for the target interfaces
    MAC_enp0s1f0d4=\$(ip link show enp0s1f0d4 | grep -oE \"([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}\" | head -1)
    MAC_enp0s1f0d5=\$(ip link show enp0s1f0d5 | grep -oE \"([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}\" | head -1)
    MAC_enp0s1f0d6=\$(ip link show enp0s1f0d6 | grep -oE \"([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}\" | head -1)
    MAC_enp0s1f0d7=\$(ip link show enp0s1f0d7 | grep -oE \"([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}\" | head -1)
    
    # Check if all MAC addresses were found
    if [ -z \"\$MAC_enp0s1f0d4\" ] || [ -z \"\$MAC_enp0s1f0d5\" ] || [ -z \"\$MAC_enp0s1f0d6\" ] || [ -z \"\$MAC_enp0s1f0d7\" ]; then
        echo \"Error: Could not retrieve all MAC addresses\"
        exit 1
    fi
    
    # Create new ctrl_map value
    NEW_CTRL_MAP=\"[\\\"NETDEV\\\",\\\"\$MAC_enp0s1f0d4\\\",\\\"\$MAC_enp0s1f0d5\\\",\\\"\$MAC_enp0s1f0d6\\\",\\\"\$MAC_enp0s1f0d7\\\",1]\"
    
    # Create a temporary file with the updated config
    TMP_FILE=$(mktemp)
    jq \".chip_list[0].ctrl_map = \$NEW_CTRL_MAP\" \$CONFIG_FILE > \$TMP_FILE
    
    # Verify the JSON is valid
    if jq empty \$TMP_FILE > /dev/null 2>&1; then
        # Backup the original file
        cp \$CONFIG_FILE \${CONFIG_FILE}.bak
        # Move the temporary file to the original location
        mv \$TMP_FILE \$CONFIG_FILE
        echo \"Successfully updated \$CONFIG_FILE with new MAC addresses\"
        echo \"MAC addresses: \$MAC_enp0s1f0d4, \$MAC_enp0s1f0d5, \$MAC_enp0s1f0d6, \$MAC_enp0s1f0d7\"
        exit 0
    else
        echo \"Error: Generated invalid JSON\"
        rm \$TMP_FILE
        exit 1
    fi
'"

if [ $? -eq 0 ]; then
    echo "es2k_skip_p4.conf file updated successfully!"
    echo " >>> Use enp0s1f0d4, enp0s1f0d5, enp0s1f0d6, enp0s1f0d7 as PRs for networking setup"
    exit 0
else
    echo "Error: Failed to update es2k_skip_p4.conf file."
    exit 1
fi
