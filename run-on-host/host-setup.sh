#!/bin/bash

function set_env_vars() {
    echo "Setting environment variables..."
    
    export SDE=/root/sabeel/p4-sde
    cd $SDE/p4_sde-nat-p4-driver/tools/setup
    source $SDE/p4_sde-nat-p4-driver/tools/setup/p4sde_env_setup.sh $SDE
    export DEPEND_INSTALL=/root/sabeel/stratum-deps/install
    export P4CP_RECIPE=/root/sabeel/networking-recipe
    export P4CP_INSTALL=/root/sabeel/networking-recipe/install
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$DEPEND_INSTALL/lib:$DEPEND_INSTALL/lib64
    export PATH=$P4CP_INSTALL/bin:$P4CP_INSTALL/sbin:$PATH
    export OUTPUT_DIR=/usr/share/stratum/lnw-v3
    export RUN_OVS=$P4CP_RECIPE/ovs/install
}

start_infrap4d() {
    printf "Starting infrap4d..."
    infrap4d
    printf "OK\n"
}

set_pipe() {
    printf "Setting pipe..."
    p4rt-ctl set-pipe br0 $OUTPUT_DIR/lnw-v3.pb.bin $OUTPUT_DIR/p4Info.txt
    printf "OK\n"
}

enable_idpf() {
    printf "Enabling IDPF driver..."
    modprobe idpf
    sleep 5
    printf "OK\n"
    printf "Launching VFs..."
    echo 4 > /sys/class/net/ens801f0/device/sriov_numvfs
    printf "OK\n"
    sleep 5
    ip -br l
}

set_env_vars
# start_infrap4d
set_pipe
enable_idpf

