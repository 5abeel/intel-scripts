#!/bin/bash

# Prerequisites:
# 1. The es2k_skip_p4.conf is edited & verified to work
#    correctly on this hw with correct pcie_bdf number
# 2. the es2k_skip_p4.conf file has all VSIs with correct MAC address added to
#    VSI-Group 1
# 3. LNWv3 artifacts present in /usr/share/stratum/lnw-v3 folder


IMC="root@100.0.0.100"
ACC="root@192.168.0.2"
HOST="root@10.166.232.1"
OUTPUT_DIR=/usr/share/stratum/lnw-v3


cleanup_acc() {
    printf "Cleaning up..."
    pkill infrap4d
    pkill ovs

    # TODO: cleanup networking interfaces, ovs-bridge, ports etc.

    printf "OK\n"
}

stop_idpf() {
    printf "Stopping IDPF driver on host..."
    rmmod idpf
    printf "OK\n"
}

check_for_first_run() {
    if [ ! -d "/opt/p4/p4-cp-nws" ]; then
        echo "/opt/p4/p4-cp-nws does not exist"
        tar -xvzf /opt/p4.tar.gz
    fi

    if [ ! -d "/usr/share/stratum/certs" ]; then
        echo "Certs not found. Generating new certs..."
        cd /usr/share/stratum
        COMMON_NAME=10.10.0.2 ./generate-certs.sh
        cd -
    fi
}

set_hugepages() {
    printf "Setting hugepages..."
    echo 512 > /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages
    echo 512 > /sys/devices/system/node/node0/hugepages/hugepages-1048576kB/nr_hugepages
    modprobe vfio-pci
    /opt/p4/p4sde/bin/vfio_bind.sh 8086:1453
    printf "OK\n"
}

set_interface_ip() {
    printf "Setting interface IP..."
    nmcli device set enp0s1f0d3 managed no
    ip a a 10.10.0.2/24 dev enp0s1f0d3
    printf "OK\n"
}

start_infrap4d() {
    printf "Starting infrap4d..."
    /opt/p4/p4-cp-nws/sbin/infrap4d --local_stratum_url="10.10.0.2:9559" --external_stratum_urls="10.10.0.2:9339,10.10.0.2:9559"
    printf "OK\n"
}

check_switchd_status() {
    retries=0
    max_retries=15

    while true; do
        if tail -5 /var/log/stratum/infrap4d.INFO | grep -q "switchd started successfully"; then
            printf "switchd started successfully\n"
            break
        else
            retries=$((retries + 1))
            if [ "$retries" -gt "$max_retries" ]; then
                printf "Failed to start switchd after %d retries\n" "$max_retries"
                break
            fi
            printf "[%d/%d] switchd not started yet, checking again in 10 seconds...\n" "$retries" "$max_retries"
            sleep 10
        fi
    done
}

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

setup_host_comms_chnl() {
    printf "Setting up comms channel on host..."

    nmcli device set ens801f0d3 managed no
    ip addr add dev ens801f0d3 10.10.0.3/24

    # Copy/overwrite certs on host from ACC (in case certs have changed)
    rm -rf /usr/share/stratum/certs
    scp -pr root@10.10.0.2:/usr/share/stratum/certs /usr/share/stratum
    printf "OK\n"
}

### Step 1: cleanup acc + stop idpf driver on host

# SSH to IMC first
ssh "$IMC" << EOF
    # SSH to ACC from IMC
    ssh "$ACC" << REMOTE
$(typeset -f cleanup_acc)

cleanup_acc
REMOTE
EOF

ssh -t "$HOST" << EOF
    $(typeset -f stop_idpf)
    stop_idpf
EOF


### Step 2: start infrap4d, set-pipe on ACC

# SSH to IMC first
ssh "$IMC" << EOF
    # SSH to ACC from IMC
    ssh "$ACC" << REMOTE
$(typeset -f check_for_first_run)
$(typeset -f set_hugepages)
$(typeset -f set_interface_ip)
$(typeset -f start_infrap4d)
$(typeset -f check_switchd_status)
$(typeset -f set_pipe)

check_for_first_run
set_hugepages
set_interface_ip
start_infrap4d
check_switchd_status
set_pipe
REMOTE
EOF


### Step 3: start IDPF driver on host + setup comms channel

ssh -t "$HOST" << EOF
    $(typeset -f start_idpf)
    $(typeset -f probe_vfs)
    $(typeset -f setup_host_comms_chnl)
    start_idpf
    sleep 5
    probe_vfs
    setup_host_comms_chnl
EOF
