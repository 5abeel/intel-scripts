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
        COMMON_NAME=10.10.0.2 ./generate-certs.sh
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
    printf "Setting interface IP..."
    nmcli device set enp0s1f0d3 managed no
    if ! ip addr show dev enp0s1f0d3 | grep -q "10.10.0.2/24"; then
        ip addr add 10.10.0.2/24 dev enp0s1f0d3
    else
        printf "IP already set. "
    fi
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

    while [ $retries -lt $max_retries ]; do
        if tail -5 /var/log/stratum/infrap4d.INFO | grep -q "switchd started successfully"; then
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
    if [ ! -f /opt/fxp-net_linux-networking/lnp.pb.bin ]; then
        echo "lnp.pb.bin file not found...creating one"
        touch /opt/fxp-net_linux-networking/ipu.bin
        /opt/p4/p4-cp-nws/bin/tdi_pipeline_builder --p4c_conf_file=/usr/share/stratum/es2k/es2k_skip_p4.conf --tdi_pipeline_config_binary_file=/opt/fxp-net_linux-networking/lnp.pb.bin
    fi
    printf "Setting pipe..."
    /opt/p4/p4-cp-nws/bin/p4rt-ctl -g 10.10.0.2:9559 set-pipe br0 /opt/fxp-net_linux-networking/lnp.pb.bin /opt/fxp-net_linux-networking/p4Info.txt
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

    nmcli device set ens801f0d3 managed no
    if ! ip addr show dev ens801f0d3 | grep -q "10.10.0.3/24"; then
        ip addr add 10.10.0.3/24 dev ens801f0d3
    else
        printf "IP already set. "
    fi

    # Copy/overwrite certs on host from ACC (in case certs have changed)
    rm -rf /usr/share/stratum/certs
    ssh-keygen -R 10.10.0.2
    ssh-keyscan -t ecdsa 10.10.0.2 >> ~/.ssh/known_hosts
    scp $SSH_OPTIONS -pr root@10.10.0.2:/usr/share/stratum/certs /usr/share/stratum
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
    scp $SSH_OPTIONS -pr root@10.10.0.2:/opt/fxp-net_linux-networking/lnp.pb.bin /var/tmp/ipsec_fixed_func.pb.bin
    scp $SSH_OPTIONS -pr root@10.10.0.2:/opt/fxp-net_linux-networking/p4Info.txt /var/tmp/linux_networking.p4info.txt
}

### Step 1: cleanup acc + stop idpf driver on host

# SSH to IMC first
ssh $SSH_OPTIONS "$IMC" << EOF
    # SSH to ACC from IMC
    ssh $SSH_OPTIONS "$ACC" << REMOTE
$(typeset -f cleanup_acc)

cleanup_acc
REMOTE
EOF

ssh $SSH_OPTIONS -t "$HOST" << EOF
    $(typeset -f stop_idpf)
    stop_idpf
EOF


### Step 2: start infrap4d, set-pipe on ACC

# SSH to IMC first
ssh $SSH_OPTIONS "$IMC" << EOF
    # SSH to ACC from IMC
    ssh $SSH_OPTIONS "$ACC" << REMOTE
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

ssh $SSH_OPTIONS -t "$HOST" << EOF
    $(typeset -f start_idpf)
    $(typeset -f setup_host_comms_chnl)
    $(typeset -f copy_ipsec_artifacts)
    start_idpf
    echo "Pausing 10s for all VFs to come up..."
    sleep 10
    setup_host_comms_chnl
    copy_ipsec_artifacts
EOF

### Step 4: Print host and ACC IDPF port data

./getvports.sh
