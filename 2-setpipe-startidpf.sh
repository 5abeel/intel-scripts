#!/bin/bash

IMC="root@100.0.0.100"
ACC="root@192.168.0.2"
HOST="root@10.166.232.1" # p7 system

set_pipe() {
    printf "Setting pipe..."
    /opt/p4/p4-cp-nws/bin/p4rt-ctl -g 10.10.0.2:9559 set-pipe br0 /usr/share/stratum/lnw-v3/lnw-v3.pb.bin /usr/share/stratum/lnw-v3/p4Info.txt
    printf "OK\n"
}

start_idpf() {
    printf "Starting IDPF driver..."
    modprobe idpf
    printf "OK\n"
    sleep 5
    printf "Launching VFs..."
    echo 4 > /sys/class/net/ens801f0/device/sriov_numvfs
    printf "OK\n"
}

probe_vfs() {
    printf "Probing VFs..."
    HOST_VF_INTF=$(ip -br l | grep ens801f0v | grep 1c | awk '{print $1}')

    echo "HOST_VF_INTF=$HOST_VF_INTF"

    nmcli device set "$HOST_VF_INTF" managed no
    ip addr add dev "$HOST_VF_INTF" 192.168.1.101/24
}


# SSH to IMC first
ssh "$IMC" << EOF
    # SSH to ACC from IMC
    ssh "$ACC" << REMOTE
$(typeset -f set_pipe)

set_pipe
REMOTE
EOF


ssh -t "$HOST" << EOF
    $(typeset -f start_idpf)
    $(typeset -f probe_vfs)
    start_idpf
    sleep 5
    probe_vfs
EOF


# SSH to IMC first
#ssh "$IMC" << EOF
#    # SSH to ACC from IMC
#    ssh "$ACC" << REMOTE
#$(typeset -f setup_network)
#$(typeset) -f start_ovs)

#setup_network
#start_ovs
#REMOTE
#EOF
