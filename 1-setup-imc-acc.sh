#!/bin/bash

# Source the environment file
source ./config.env

LOCAL_ARTIFACTS_FOLDER="./target_copy/lnp"
LOCAL_PKG_FILE="./target_copy/lnp/fxp-net_linux-networking.pkg"
LOCAL_CUSTOM_LOAD_FILE="./target_copy/load_custom_pkg.sh"
LOCAL_ES2K_SKIP_P4_FILE="./target_copy/es2k_skip_p4.conf"
LOCAL_ACC_ENV_SETUP_FILE="./target_copy/setup_acc_env.sh"

REMOTE_PATH1_IMC="/work/scripts/"
REMOTE_FILES_TO_DELETE_IMC=("fxp-net_linux-networking.pkg" "load_custom_pkg.sh")  # Files to delete on IMC
REMOTE_PATH1_ACC="/usr/share/stratum/"
REMOTE_ACC_PKG_NAME="lnp"

# Run command on host
echo "Stopping IDPF on host..."
ssh $SSH_OPTIONS $HOST "rmmod idpf"


# Function to check if a machine is up
check_machine_up() {
    local machine_name=$1
    local machine_ip=$2
    local max_attempts=30
    local attempt=1

    echo "Waiting for $machine_name to come up..."
    while [ $attempt -le $max_attempts ]; do
        if ssh $SSH_OPTIONS $machine_ip "exit" &>/dev/null; then
            echo "$machine_name is up!"
            return 0
        fi
        echo "Attempt $attempt: $machine_name not yet accessible. Waiting..."
        sleep 10
        ((attempt++))
    done
    echo "Error: $machine_name did not come up after $max_attempts attempts."
    return 1
}

# Delete old .pkg files on IMC
echo "Deleting old .pkg files on IMC..."
for file in "${REMOTE_FILES_TO_DELETE_IMC[@]}"
do
    ssh $SSH_OPTIONS $IMC "rm -f $REMOTE_PATH1_IMC/$file"
done

# Delete old files on ACC
echo "Deleting old artifacts on ACC..."
ssh $SSH_OPTIONS $IMC "ssh $SSH_OPTIONS $ACC 'rm -rf $REMOTE_PATH1_ACC/$REMOTE_ACC_PKG_NAME'"

# Copy files to IMC
echo "Copying files to IMC..."
scp $SSH_OPTIONS $LOCAL_PKG_FILE $LOCAL_CUSTOM_LOAD_FILE $IMC:$REMOTE_PATH1_IMC

# Reboot IMC (which will also reboot ACC)
echo "Rebooting IMC..."
ssh $SSH_OPTIONS $IMC "reboot"

sleep 2

# Wait for IMC to come up
if ! check_machine_up "IMC" $IMC; then
    echo "Failed to connect to IMC. Exiting."
    exit 1
fi

# Verify values in host config
printf "Verifying node config on IMC..."
if ssh $SSH_OPTIONS $IMC "
    [ -L /etc/dpcp/package/default_pkg.pkg ] && [ \$(readlink /etc/dpcp/package/default_pkg.pkg) = '/etc/dpcp/package/fxp-net_linux-networking.pkg' ] &&
    grep -q 'sem_num_pages = 28' /etc/dpcp/cfg/default_cp_init.cfg &&
    grep -q 'lem_num_pages = 32' /etc/dpcp/cfg/default_cp_init.cfg &&
    grep -q 'mod_num_pages = 2' /etc/dpcp/cfg/default_cp_init.cfg &&
    grep -q 'cxp_num_pages = 5' /etc/dpcp/cfg/default_cp_init.cfg &&
    grep -q 'acc_apf = 16' /etc/dpcp/cfg/default_cp_init.cfg &&
    grep -q 'cpf_host = 4' /etc/dpcp/cfg/default_cp_init.cfg &&
    grep -qP 'comm_vports\s*=\s*\(\(\[5,0\],\[4,0\]\),\(\[0,3\],\[4,3\]\)\)' /etc/dpcp/cfg/default_cp_init.cfg
"; then
    echo "Verified for LNW!"
else
    echo "Error: Node config required values not found in IMC. Exiting."
    exit 1
fi

# Wait for ACC to come up
echo "Waiting for ACC to come up..."
attempt=1
while [ $attempt -le 30 ]; do
    if ssh $SSH_OPTIONS $IMC "ssh $SSH_OPTIONS $ACC 'exit'" &>/dev/null; then
        echo "ACC is up!"
        break
    fi
    echo "Attempt $attempt: ACC not yet accessible. Waiting..."
    sleep 10
    ((attempt++))
done

if [ $attempt -gt 30 ]; then
    echo "Error: ACC did not come up after 30 attempts."
    exit 1
fi

# Copy files to ACC through IMC
echo "Copying artifacts folder to ACC..."
scp $SSH_OPTIONS -r -o ProxyCommand="ssh $SSH_OPTIONS -W %h:%p $IMC" $LOCAL_ARTIFACTS_FOLDER $ACC:$REMOTE_PATH1_ACC
echo "Copying es2k_skip_p4.conf file to ACC..."
scp $SSH_OPTIONS -o ProxyCommand="ssh $SSH_OPTIONS -W %h:%p $IMC" $LOCAL_ES2K_SKIP_P4_FILE $ACC:$REMOTE_PATH1_ACC/es2k/
echo "Copying setup_acc_env.sh to ACC..."
scp $SSH_OPTIONS -o ProxyCommand="ssh $SSH_OPTIONS -W %h:%p $IMC" $LOCAL_ACC_ENV_SETUP_FILE $ACC:~/

# Sync time
echo
echo "Sync'ing time..."
./sync_time.sh

# Check for folders and extract p4.tar.gz on ACC if first time
echo "Checking folders and running command on ACC if needed..."
ssh $SSH_OPTIONS -o ProxyCommand="ssh $SSH_OPTIONS -W %h:%p $IMC" $ACC "
    if [ ! -d /opt/p4/p4sde ] || [ ! -d /opt/p4/p4-cp-nws ]; then
        echo 'p4-cp-nws and p4sde folders not found. Extracting p4.tar.gz...'
        tar -xvzf /opt/p4.tar.gz -C /opt
        if [ $? -eq 0 ]; then
            echo 'Extraction successful'
        else
            echo 'Extraction failed'
            exit 1
        fi
    else
        echo 'Required folders already exist'
    fi
" || { echo "Failed to run command on ACC"; exit 1; }


# Run vfio_bind on ACC
echo
echo "Running vfio_bind on ACC to get pcie_bdf and iommu_grp_number..."
ssh $SSH_OPTIONS -o ProxyCommand="ssh $SSH_OPTIONS -W %h:%p $IMC" $ACC "modprobe vfio-pci && /opt/p4/p4sde/bin/vfio_bind.sh 8086:1453"

echo "Setup complete!"
