#!/bin/bash

# Source the environment file
source ./config.env

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

# Run command on host
echo "Stopping IDPF on host..."
ssh $SSH_OPTIONS $HOST "rmmod idpf"

# Reboot IMC
echo "Rebooting IMC..."
ssh $SSH_OPTIONS $IMC "reboot"

sleep 2

# Wait for IMC to come up
if ! check_machine_up $IMC; then
    echo "Failed to connect to IMC. Exiting."
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

# Sync time
echo "Sync'ing time..."
./sync_time.sh

echo
echo "All tasks completed successfully."
echo
