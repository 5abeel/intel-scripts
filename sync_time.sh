#!/bin/bash

# Timezone to set
TIMEZONE="America/Los_Angeles"

IMC="root@100.0.0.100"
ACC="root@192.168.0.2"
HOST="root@10.166.232.1" # P7 system

SSH_OPTIONS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR"

# Define the commands to execute
COMMANDS=(
    "systemctl stop firewalld"
    "systemctl disable firewalld"
    "timedatectl set-local-rtc 0"
    "timedatectl set-ntp true"
    "systemctl disable --now chronyd"
    "timedatectl set-timezone '$TIMEZONE'"
)

# Get the current timestamp from the local machine
LOCAL_TIMESTAMP=$(TZ="$TIMEZONE" date +"%Y-%m-%d %H:%M:%S")

# Function to refresh IMC SSH key
refresh_imc_key_on_local_machine() {
    echo "Updating IMC key on local machine..."
    ssh-keygen -R 100.0.0.100
    ssh-keyscan -t ecdsa 100.0.0.100 >> ~/.ssh/known_hosts
}

# Function to update ACC key on IMC
refresh_acc_key_on_imc() {
    echo "Updating ACC key on IMC..."
    ssh $SSH_OPTIONS "$IMC" "ssh-keygen -R 192.168.0.2"
    ssh $SSH_OPTIONS "$IMC" "ssh-keyscan -t ecdsa 192.168.0.2 >> ~/.ssh/known_hosts"
}

# Function to execute commands on the remote hosts
execute_commands() {
    # Execute commands on the first remote host (IMC)
    for command in "${COMMANDS[@]}"; do
        echo "Executing command on IMC: $command"
        ssh $SSH_OPTIONS "$IMC" "$command" &>/dev/null
    done

    # Execute the last command with the local timestamp on the first remote host (IMC)
    echo "Executing command on IMC: timedatectl set-time '$LOCAL_TIMESTAMP'"
    ssh $SSH_OPTIONS "$IMC" "timedatectl set-time '$LOCAL_TIMESTAMP'" &>/dev/null

    # Execute commands on the second remote host (daisy-chained) (ACC)
    for command in "${COMMANDS[@]}"; do
        echo "Executing command on ACC: $command"
        ssh $SSH_OPTIONS -J "$IMC" "$ACC" "$command" &>/dev/null
    done

    # Execute the last command with the local timestamp on the second remote host (ACC)
    echo "Executing command on ACC: timedatectl set-time '$LOCAL_TIMESTAMP'"
    ssh $SSH_OPTIONS -J "$IMC" "$ACC" "timedatectl set-time '$LOCAL_TIMESTAMP'" &>/dev/null
    
     # Execute commands on the third host (Host)
    for command in "${COMMANDS[@]}"; do
        echo "Executing command on Host: $command"
        ssh $SSH_OPTIONS "$HOST" "$command" &>/dev/null
    done

    # Execute the last command with the local timestamp on the third remote host (Host)
    echo "Executing command on Host: timedatectl set-time '$LOCAL_TIMESTAMP'"
    ssh $SSH_OPTIONS "$HOST" "timedatectl set-time '$LOCAL_TIMESTAMP'" &>/dev/null
}

# Execute the commands
refresh_imc_key_on_local_machine
refresh_acc_key_on_imc
execute_commands

