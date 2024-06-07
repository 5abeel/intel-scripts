#!/bin/bash

IMC="root@100.0.0.100"
ACC="root@192.168.0.2"
HOST="root@10.166.232.1"
OUTPUT_DIR=/usr/share/stratum/lnw-v3


cleanup() {
    printf "Cleaning up..."
    pkill infrap4d
    pkill ovs
    printf "OK\n"
}

check_for_first_run() {
    if [ ! -d "/opt/p4/p4-cp-nws" ]; then
        echo "/opt/p4/p4-cp-nws does not exist"
        if [ -f "/opt/p4.tar.gz"]; then
            tar -xvzf /opt/p4.tar.gz
        fi
    fi

    if [ ! -d "usr/share/stratum/certs" ]; then
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
    p4rt-ctl -g 10.10.0.2:9559 set-pipe br0 $OUTPUT_DIR/lnp.pb.bin $OUTPUT_DIR/p4Info.txt
    printf "OK\n"
}


enable_idpf_on_host() {
    printf "Bringing up IDPF + VFs on host..."
    ssh "$HOST" "modprobe idpf"
    sleep 5
    ssh "$HOST" "echo 4 > /sys/class/net/ens801f0/device/sriov_numvfs"
    printf "OK\n"
}

# SSH to IMC first
ssh "$IMC" << EOF
    # SSH to ACC from IMC
    ssh "$ACC" << REMOTE
$(typeset -f cleanup)
$(typeset -f check_for_first_run)
$(typeset -f set_hugepages)
$(typeset -f set_interface_ip)
$(typeset -f start_infrap4d)
$(typeset -f check_switchd_status)

cleanup
check_for_first_run
set_hugepages
set_interface_ip
start_infrap4d
check_switchd_status
REMOTE
EOF

