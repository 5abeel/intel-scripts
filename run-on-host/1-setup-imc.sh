#!/bin/bash

# Define variables
IMC="root@100.0.0.100"
HOST="root@10.166.224.130" # P9

LOCAL_ARTIFACTS_FOLDER="./target_copy/lnp"
LOCAL_PKG_FILE="./target_copy/lnp/fxp-net_linux-networking.pkg"
LOCAL_CUSTOM_LOAD_FILE="./target_copy/load_custom_pkg.sh"

REMOTE_PATH1_IMC="/work/scripts/"
REMOTE_FILES_TO_DELETE_IMC=("fxp-net_linux-networking.pkg" "load_custom_pkg.sh")  # Files to delete on IMC

# SSH options to suppress warnings and errors
SSH_OPTIONS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR"


# Run command on host
echo "Stopping IDPF on host..."
ssh $SSH_OPTIONS $HOST "rmmod idpf"


# Function to check if a machine is up
check_machine_up() {
    local machine=$1
    local max_attempts=30
    local attempt=1

    echo "Waiting for $machine to come up..."
    while [ $attempt -le $max_attempts ]; do
        if ssh $SSH_OPTIONS $machine "exit" &>/dev/null; then
            echo "$machine is up!"
            return 0
        fi
        echo "Attempt $attempt: $machine not yet accessible. Waiting..."
        sleep 10
        ((attempt++))
    done
    echo "Error: $machine did not come up after $max_attempts attempts."
    return 1
}

# Delete old .pkg files on IMC
echo "Deleting old .pkg files on IMC..."
for file in "${REMOTE_FILES_TO_DELETE_IMC[@]}"
do
    ssh $SSH_OPTIONS $IMC "rm -f $REMOTE_PATH1_IMC/$file"
done

# Copy files to IMC
echo "Copying files to IMC..."
scp $SSH_OPTIONS $LOCAL_PKG_FILE $LOCAL_CUSTOM_LOAD_FILE $IMC:$REMOTE_PATH1_IMC

# Reboot IMC
echo "Rebooting IMC..."
ssh $SSH_OPTIONS $IMC "reboot"

sleep 2

# Wait for IMC to come up
if ! check_machine_up $IMC; then
    echo "Failed to connect to IMC. Exiting."
    exit 1
fi

# Verify values in host config
echo "Checking for specific values in IMC..."
if ssh $SSH_OPTIONS $IMC "
    [ -L /etc/dpcp/package/default_pkg.pkg ] && [ \$(readlink /etc/dpcp/package/default_pkg.pkg) = '/etc/dpcp/package/fxp-net_linux-networking.pkg' ] &&
    grep -q 'sem_num_pages = 28' /etc/dpcp/cfg/default_cp_init.cfg &&
    grep -q 'lem_num_pages = 10' /etc/dpcp/cfg/default_cp_init.cfg &&
    grep -q 'mod_num_pages = 2' /etc/dpcp/cfg/default_cp_init.cfg &&
    grep -q 'acc_apf = 16' /etc/dpcp/cfg/default_cp_init.cfg &&
    grep -q 'cpf_host = 0' /etc/dpcp/cfg/default_cp_init.cfg &&
    grep -qP 'comm_vports\s*=\s*\(\(\[5,0\],\[4,0\]\),\(\[0,3\],\[4,3\]\)\)' /etc/dpcp/cfg/default_cp_init.cfg
"; then
    echo "Node config verified on IMC!"
else
    echo "Error: Node config required values not found in IMC. Exiting."
    exit 1
fi

# Sync time
echo
echo "Sync'ing time..."
../sync_time.sh

echo "Setup complete!"
