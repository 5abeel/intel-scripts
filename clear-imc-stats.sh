#!/bin/bash

# Source the environment file
source ./config.env

ssh $SSH_OPTIONS "$IMC" << 'EOF'
for i in $(seq 0 26); do 
    devmem $((0x2024A0204C + i*4)) 32 0
done
for i in $(seq 0 19); do 
    devmem $((0x202490204C + i*4)) 32 0
done
EOF
