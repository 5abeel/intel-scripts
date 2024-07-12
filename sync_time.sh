#!/bin/bash

# Define the first remote host and credentials
REMOTE_HOST_1="100.0.0.100"
USERNAME_1="root"

# Define the second remote host and credentials
REMOTE_HOST_2="192.168.0.2"
USERNAME_2="root"

# Define the third remote host and credentials
REMOTE_HOST_3="10.166.232.1" # P7 system
USERNAME_3="root"

SSH_OPTIONS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR"

# Define the commands to execute
COMMANDS=(
    "systemctl stop firewalld"
    "systemctl disable firewalld"
    "timedatectl set-local-rtc 0"
    "timedatectl set-ntp true"
    "systemctl disable --now chronyd"
    "timedatectl set-timezone 'America/Los_Angeles'"
)

# Get the current timestamp from the local machine
LOCAL_TIMESTAMP=$(TZ="America/Los_Angeles" date +"%Y-%m-%d %H:%M:%S")

# Function to execute commands on the remote hosts
execute_commands() {
    # Execute commands on the first remote host (IMC)
    for command in "${COMMANDS[@]}"; do
        echo "Executing command on IMC: $command"
        ssh $SSH_OPTIONS "$USERNAME_1@$REMOTE_HOST_1" "$command" &>/dev/null
    done

    # Execute the last command with the local timestamp on the first remote host (IMC)
    echo "Executing command on IMC: timedatectl set-time '$LOCAL_TIMESTAMP'"
    ssh $SSH_OPTIONS "$USERNAME_1@$REMOTE_HOST_1" "timedatectl set-time '$LOCAL_TIMESTAMP'" &>/dev/null

    # Execute commands on the second remote host (daisy-chained) (ACC)
    for command in "${COMMANDS[@]}"; do
        echo "Executing command on ACC: $command"
        ssh $SSH_OPTIONS -J "$USERNAME_1@$REMOTE_HOST_1" "$USERNAME_2@$REMOTE_HOST_2" "$command" &>/dev/null
    done

    # Execute the last command with the local timestamp on the second remote host (ACC)
    echo "Executing command on ACC: timedatectl set-time '$LOCAL_TIMESTAMP'"
    ssh $SSH_OPTIONS -J "$USERNAME_1@$REMOTE_HOST_1" "$USERNAME_2@$REMOTE_HOST_2" "timedatectl set-time '$LOCAL_TIMESTAMP'" &>/dev/null
    
     # Execute commands on the third host (Host)
    for command in "${COMMANDS[@]}"; do
        echo "Executing command on Host: $command"
        ssh $SSH_OPTIONS "$USERNAME_3@$REMOTE_HOST_3" "$command" &>/dev/null
    done

    # Execute the last command with the local timestamp on the third remote host (Host)
    echo "Executing command on Host: timedatectl set-time '$LOCAL_TIMESTAMP'"
    ssh $SSH_OPTIONS "$USERNAME_3@$REMOTE_HOST_3" "timedatectl set-time '$LOCAL_TIMESTAMP'" &>/dev/null
}

# Execute the commands
execute_commands

