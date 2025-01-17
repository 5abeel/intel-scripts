#!/bin/bash

# Source the environment file
source ./config.env

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

# Copy files to IMC is not "default pkg"
if [ "$PKG_NAME" != "default" ]; then
    echo "Copying files to IMC..."
    scp $SSH_OPTIONS $LOCAL_PKG_FILE $LOCAL_CUSTOM_LOAD_FILE $IMC:$REMOTE_PATH1_IMC
else
    echo "Skipping file copy to IMC as PKG_NAME is set to 'default'"
fi

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
if ! ./verify_node_policy.sh; then
    echo "Error: Node policy verification failed. Exiting."
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
scp $SSH_OPTIONS -o ProxyCommand="ssh $SSH_OPTIONS -W %h:%p $IMC" $LOCAL_ES2K_SKIP_P4_FILE $ACC:/usr/share/stratum/es2k/
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


## Verify values in es2k_skip_p4.config
if ! ./verify_es2k_skip_file.sh; then
    echo "Error: /usr/share/stratum/es2k/es2k_skip_p4.conf contains incorrect MAC addresses that do not exist on system!"
    echo "       Edit file before proceeding"
    exit 1
fi

echo "Setup complete!"
