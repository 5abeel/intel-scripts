#!/bin/bash

# Prerequisites:
# 1. The es2k_skip_p4.conf is edited & verified to work
#    correctly on this hw with correct pcie_bdf number
# 2. the es2k_skip_p4.conf file has all VSIs with correct MAC address added to
#    VSI-Group 1
# 3. LNW artifacts present in /opt/fxp-net_linux-networking folder

# Source the environment file
source ./config.env

cleanup_acc() {
    printf "Stopping infrap4d and ovs..."
    pkill infrap4d
    pkill ovs
    rm -f /var/log/stratum/infrap4d.INFO # remove the symlink file to avoid false reads of switchd started successfully

    # TODO: cleanup networking interfaces, ovs-bridge, ports etc.

    printf "OK\n"
}

stop_idpf() {
    printf "Stopping IDPF driver on host..."
    if lsmod | grep -q "^idpf "; then
        if ! rmmod idpf; then
            printf "Failed to remove idpf module. It may be in use.\n"
            return 1
        fi
        printf "OK\n"
    else
        printf "IDPF driver not loaded. Skipping.\n"
    fi
    return 0
}

check_for_first_run() {
    if [ ! -d "/usr/share/stratum/certs" ]; then
        echo "Certs not found. Generating new certs..."
        cd /usr/share/stratum
        COMMON_NAME=$GRPC_ADDR_IP ./generate-certs.sh
        cd -
    fi
}

set_hugepages() {
    printf "Setting hugepages..."
    echo 512 > /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages
    echo 512 > /sys/devices/system/node/node0/hugepages/hugepages-1048576kB/nr_hugepages
    printf "OK\n"
    printf "vfio_bind..."
    modprobe vfio-pci
    /opt/p4/p4sde/bin/vfio_bind.sh 8086:1453
}

set_interface_ip() {
    local interface="enp0s1f0d3"
    local max_attempts=30
    local wait_time=2

    printf "Waiting for interface %s to come up..." "$interface"

    for ((i=1; i<=max_attempts; i++)); do
        if ip link show dev "$interface" &>/dev/null; then
            printf "OK\n"
            break
        fi
        printf "."
        sleep $wait_time
        if [ $i -eq $max_attempts ]; then
            printf "\nError: Interface %s did not come up after %d seconds\n" "$interface" $((max_attempts * wait_time))
            return 1
        fi
    done

    printf "Setting interface ($interface = $GRPC_ADDR_IP)..."
    nmcli device set "$interface" managed no
    if ! ip addr show dev "$interface" | grep -q "$GRPC_ADDR_IP"; then
        ip addr add "$GRPC_ADDR_IP/24" dev "$interface"
    else
        printf "IP already set. "
    fi
    printf "OK\n"
}

start_infrap4d() {
    printf "Starting infrap4d..."
    /opt/p4/p4-cp-nws/sbin/infrap4d --local_stratum_url="$GRPC_ADDR_IP:9559" --external_stratum_urls="$GRPC_ADDR_IP:9339,$GRPC_ADDR_IP:9559"
    printf "OK\n"
}

check_switchd_status() {
    retries=0
    max_retries=15

    while [ $retries -lt $max_retries ]; do
        if tail -5 /var/log/stratum/infrap4d.INFO 2>/dev/null | grep -q "switchd started successfully"; then
            printf "switchd started successfully\n"
            return 0
        else
            retries=$((retries + 1))
            printf "switchd not started yet, checking again in 10 seconds...\n" "$retries" "$max_retries"
            sleep 10
        fi
    done

    printf "Failed to start switchd after %d retries\n" "$max_retries"
    return 1
}

set_pipe() {
    if [ ! -f /opt/$PKG_NAME/pipe.pb.bin ]; then
        echo "pipe.pb.bin file not found...creating one"
        touch /opt/$PKG_NAME/ipu.bin
        /opt/p4/p4-cp-nws/bin/tdi_pipeline_builder --p4c_conf_file=/usr/share/stratum/es2k/es2k_skip_p4.conf --tdi_pipeline_config_binary_file=/opt/$PKG_NAME/pipe.pb.bin
    fi

    printf "Setting pipe..."
    /opt/p4/p4-cp-nws/bin/p4rt-ctl -g $GRPC_ADDR_IP:9559 set-pipe br0 /opt/$PKG_NAME/pipe.pb.bin /opt/$PKG_NAME/p4Info.txt
    printf "OK\n"
}

start_idpf() {
    printf "Starting IDPF driver on host..."
    modprobe idpf
    printf "OK\n"
    sleep 5
    printf "Launching VFs..."
    echo 4 > /sys/class/net/ens801f0/device/sriov_numvfs
    printf "OK\n"
}

setup_host_comms_chnl() {
    printf "Setting up comms channel on host..."
    echo "checking for $HOST_COMMS_IP"
    nmcli device set ens801f0d3 managed no
    if ! ip addr show dev ens801f0d3 | grep -q "$HOST_COMMS_IP"; then
        ip addr add $HOST_COMMS_IP/24 dev ens801f0d3
    else
        printf "IP already set. "
    fi

    # Copy/overwrite certs on host from ACC (in case certs have changed)
    rm -rf /usr/share/stratum/certs
    ssh-keygen -R $GRPC_ADDR_IP
    ssh-keyscan -t ecdsa $GRPC_ADDR_IP >> ~/.ssh/known_hosts
    scp $SSH_OPTIONS -pr root@$GRPC_ADDR_IP:/usr/share/stratum/certs /usr/share/stratum
    printf "OK\n"
}

copy_ipsec_artifacts() {
    # IPsec-Recipe has hardcoded values which requires following files. Copy from ACC artifacts
    # to following location
    # /var/tmp/ipsec_fixed_func.pb.bin
    # /var/tmp/linux_networking.p4info.txt
    printf "Copying P4 artifacts from ACC to host (for ipsec-recipe)..."
    rm -rf /var/tmp/ipsec_fixed_func.pb.bin
    rm -rf /var/tmp/linux_networking.p4info.txt
    scp $SSH_OPTIONS -pr root@$GRPC_ADDR_IP:/opt/fxp-net_linux-networking/pipe.pb.bin /var/tmp/ipsec_fixed_func.pb.bin
    scp $SSH_OPTIONS -pr root@$GRPC_ADDR_IP:/opt/fxp-net_linux-networking/p4Info.txt /var/tmp/linux_networking.p4info.txt
}

## Step 0: Verify values in es2k_skip_p4.config
if ! ./verify_es2k_skip_file.sh; then
    echo "Error: /usr/share/stratum/es2k/es2k_skip_p4.conf contains incorrect MAC addresses that do not exist on system!"
    echo "       Edit file before proceeding"
    exit 1
fi

### Step 1: cleanup acc + stop idpf driver on host
ssh $SSH_OPTIONS -o ProxyCommand="ssh $SSH_OPTIONS -W %h:%p $IMC" "$ACC" << EOF
    $(declare -f cleanup_acc)
    cleanup_acc
EOF

ssh $SSH_OPTIONS -t "$HOST" << EOF
    $(declare -f stop_idpf)
    stop_idpf
EOF

### Step 2: start infrap4d, set-pipe on ACC
ssh $SSH_OPTIONS -o ProxyCommand="ssh $SSH_OPTIONS -W %h:%p $IMC" "$ACC" << EOF
    $(declare -f check_for_first_run)
    $(declare -f set_hugepages)
    $(declare -f set_interface_ip)
    $(declare -f start_infrap4d)
    $(declare -f check_switchd_status)
    $(declare -f set_pipe)

    # Export the IP addresses needed for configuration
    export GRPC_ADDR_IP=$GRPC_ADDR_IP
    export HOST_COMMS_IP=$HOST_COMMS_IP
    export PKG_NAME=$PKG_NAME

    check_for_first_run
    set_hugepages
    set_interface_ip
    start_infrap4d
    check_switchd_status
    set_pipe
EOF

### Step 3: start IDPF driver on host + setup comms channel
ssh $SSH_OPTIONS -t "$HOST" << EOF
    $(declare -f start_idpf)
    $(declare -f setup_host_comms_chnl)
    $(declare -f copy_ipsec_artifacts)

    # Export the IP addresses needed for configuration
    export GRPC_ADDR_IP=$GRPC_ADDR_IP
    export HOST_COMMS_IP=$HOST_COMMS_IP

    start_idpf
    echo "Pausing 10s for all VFs to come up..."
    sleep 10
    setup_host_comms_chnl
    copy_ipsec_artifacts
EOF

### Step 4: Print host and ACC IDPF port data
./getvports.sh
