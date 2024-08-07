#!/bin/bash

# Source the environment file where IPs are defined
source ./config.env

get_mac_address() {
    local interface=$1
    local mac_address=$(ip link show "$interface" | awk '/ether/ {print $2}')
    echo "$mac_address"
}

get_second_byte() {
    local mac_address=$1
    # Extract the second byte from the MAC address
    local second_byte=$(echo "$mac_address" | cut -d':' -f2)
    echo "$second_byte"
}

# Configure IP address on Host and get VSI and MAC address
read VSI_HOST MAC_HOST < <(ssh $SSH_OPTIONS "$HOST" "
    # Configure IP address on the specified interface
    nmcli device set "$HOST_VF_INTF" managed no
    ip addr add $HOST_VF_IP dev $HOST_VF_INTF
    ip link set $HOST_VF_INTF up
    # Function to retrieve the MAC address and second byte
    $(declare -f get_mac_address)
    $(declare -f get_second_byte)
    # Get MAC address and VSI from Host
    MAC_ADDRESS=\$(get_mac_address $HOST_VF_INTF)
    VSI=\$(get_second_byte \$MAC_ADDRESS)
    echo \$VSI \$MAC_ADDRESS
")

# Ensure VSI_HOST is not empty
if [ -z "$VSI_HOST" ]; then
    echo "Failed to retrieve VSI from Host."
    exit 1
fi

# Use SSH ProxyCommand to connect to ACC through IMC
ssh $SSH_OPTIONS -o ProxyCommand="ssh $SSH_OPTIONS -W %h:%p $IMC" "$ACC" << EOF
    # Source the environment file
    source ~/setup_acc_env.sh
    
    # Function to retrieve the MAC address and second byte
    $(declare -f get_mac_address)
    $(declare -f get_second_byte)
    
    # Get VSIs and MAC addresses from ACC
    MAC_ACC_PR1=\$(get_mac_address "$ACC_PR1_INTF")
    VSI_ACC_PR1=\$(get_second_byte "\$MAC_ACC_PR1")
    MAC_ACC_PR2=\$(get_mac_address "$ACC_PR2_INTF")
    VSI_ACC_PR2=\$(get_second_byte "\$MAC_ACC_PR2")
    
    # Ensure VSI_ACC_PR1 and VSI_ACC_PR2 are not empty
    if [ -z "\$VSI_ACC_PR1" ] || [ -z "\$VSI_ACC_PR2" ]; then
        echo "Failed to retrieve VSI from ACC interfaces."
        exit 1
    fi
    
    # Convert VSI values to decimal
    HOST_VF_VSI=\$((0x$VSI_HOST))
    ACC_PR1_VSI=\$((0x\$VSI_ACC_PR1))
    ACC_PR2_VSI=\$((0x\$VSI_ACC_PR2))
    
    # Port numbers (VSI+16)
    HOST_VF_PORT=\$((HOST_VF_VSI + 16))
    ACC_PR1_PORT=\$((ACC_PR1_VSI + 16))
    ACC_PR2_PORT=\$((ACC_PR2_VSI + 16))
    
    # Export the VSI & PORT values
    export HOST_VF_VSI HOST_VF_PORT
    export ACC_PR1_VSI ACC_PR1_PORT
    export ACC_PR2_VSI ACC_PR2_PORT
    echo "Running commands on ACC with VSI and PORT values..."
    echo "Host VF interface: $HOST_VF_INTF, MAC: $MAC_HOST, VSI: \$HOST_VF_VSI, Port: \$HOST_VF_PORT"
    echo "ACC PR1 interface: $ACC_PR1_INTF, MAC: \$MAC_ACC_PR1, VSI: \$ACC_PR1_VSI, Port: \$ACC_PR1_PORT"
    echo "ACC PR2 interface: $ACC_PR2_INTF, MAC: \$MAC_ACC_PR2, VSI: \$ACC_PR2_VSI, Port: \$ACC_PR2_PORT"
    
    # Add the provided commands using \$P4RT_CTL_CMD
    echo "Programming P4 tables..."
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.tx_source_port "vmeta.common.vsi=\$HOST_VF_VSI/2047,priority=1,action=linux_networking_control.set_source_port(\$HOST_VF_PORT)"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.tx_acc_vsi "vmeta.common.vsi=\$ACC_PR1_VSI,zero_padding=0,action=linux_networking_control.l2_fwd_and_bypass_bridge(\$HOST_VF_PORT)"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.vsi_to_vsi_loopback "vmeta.common.vsi=\$ACC_PR1_VSI,target_vsi=\$HOST_VF_VSI,action=linux_networking_control.fwd_to_vsi(\$HOST_VF_PORT)"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.vsi_to_vsi_loopback "vmeta.common.vsi=\$HOST_VF_VSI,target_vsi=\$ACC_PR1_VSI,action=linux_networking_control.fwd_to_vsi(\$ACC_PR1_PORT)"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.source_port_to_pr_map "user_meta.cmeta.source_port=\$HOST_VF_PORT,zero_padding=0,action=linux_networking_control.fwd_to_vsi(\$ACC_PR1_PORT)"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.rx_source_port "vmeta.common.port_id=$PHY_PORT,zero_padding=0,action=linux_networking_control.set_source_port($PHY_PORT)"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.rx_phy_port_to_pr_map "vmeta.common.port_id=$PHY_PORT,zero_padding=0,action=linux_networking_control.fwd_to_vsi(\$ACC_PR2_PORT)"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.source_port_to_pr_map "user_meta.cmeta.source_port=$PHY_PORT,zero_padding=0,action=linux_networking_control.fwd_to_vsi(\$ACC_PR2_PORT)"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.tx_acc_vsi "vmeta.common.vsi=\$ACC_PR2_VSI,zero_padding=0,action=linux_networking_control.l2_fwd_and_bypass_bridge($PHY_PORT)"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.ipv4_lpm_root_lut "user_meta.cmeta.bit16_zeros=4/65535,priority=2048,action=linux_networking_control.ipv4_lpm_root_lut_action(0)"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=0/7,priority=1,action=linux_networking_control.bypass"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=1/7,priority=1,action=linux_networking_control.bypass"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=2/7,priority=1,action=linux_networking_control.bypass"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=3/7,priority=1,action=linux_networking_control.bypass"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=4/7,priority=1,action=linux_networking_control.bypass"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=5/7,priority=1,action=linux_networking_control.bypass"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=6/7,priority=1,action=linux_networking_control.bypass"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=7/7,priority=1,action=linux_networking_control.bypass"
    
    # Start OVS
    echo "Starting OVS..."
    export RUN_OVS=/opt/p4/p4-cp-nws
    pkill -9 ovsdb-server
    pkill -9 ovsdb-vswitchd
    rm -rf \$RUN_OVS/etc/openvswitch
    rm -rf \$RUN_OVS/var/run/openvswitch
    mkdir -p \$RUN_OVS/etc/openvswitch/
    mkdir -p \$RUN_OVS/var/run/openvswitch
    ovsdb-tool create \$RUN_OVS/etc/openvswitch/conf.db \\
    \$RUN_OVS/share/openvswitch/vswitch.ovsschema
    ovsdb-server \\
    --remote=punix:\$RUN_OVS/var/run/openvswitch/db.sock \\
    --remote=db:Open_vSwitch,Open_vSwitch,manager_options \\
    --pidfile --detach
    ovs-vsctl --no-wait init
    mkdir -p /tmp/logs
    ovs-vswitchd --pidfile --detach --mlockall \\
    --log-file=/tmp/logs/ovs-vswitchd.log --grpc-addr="10.10.0.2"
    ovs-vsctl set Open_vSwitch . other_config:n-revalidator-threads=1
    ovs-vsctl set Open_vSwitch . other_config:n-handler-threads=1
    
    # Run mode-specific commands
    if [ "$MODE" = "UNTAGGED" ]; then
        echo "Adding OVS bridge and adding ports (UNTAGGED mode)..."
        ovs-vsctl add-br br-intrnl
        ovs-vsctl add-port br-intrnl $ACC_PR1_INTF
        ovs-vsctl add-port br-intrnl $ACC_PR2_INTF
        ifconfig br-intrnl up
        ovs-vsctl show
    elif [ "$MODE" = "VXLAN" ]; then
        echo "Adding OVS bridge and adding ports (VXLAN mode)..."
        ovs-vsctl add-br br-intrnl
        ovs-vsctl add-port br-intrnl $ACC_PR1_INTF
        ovs-vsctl add-port br-intrnl vxlan1 -- set interface vxlan1 type=vxlan \\
        options:local_ip=10.1.1.1 options:remote_ip=10.1.1.2 options:key=10 options:dst_port=4789
        ifconfig br-intrnl up
        sleep 1
        ovs-vsctl add-br br-tunl
        ovs-vsctl add-port br-tunl $ACC_PR2_INTF
        ifconfig br-tunl 1.1.1.1/24 up
        sleep 1
        ip link add dev TEP10 type dummy
        sleep 1
        ifconfig TEP10 10.1.1.1/24 up
        sleep 2
        # ip route change 10.1.1.0/24 via 1.1.1.2 dev br-tunl
        # Attempt 'ip route change', if it fails, try 'ip route add'
        if ! ip route change 10.1.1.0/24 via 1.1.1.2 dev br-tunl; then
            echo "ip route change failed, attempting ip route add..."
            ip route add 10.1.1.0/24 via 1.1.1.2 dev br-tunl
        fi
        ovs-vsctl show
    else
        echo "Invalid MODE specified. Please use UNTAGGED or VXLAN."
        exit 1
    fi
EOF

echo ""
echo ">> ACC config completed!"
echo ""
echo "Configuring LP interfaces..."
# SSH into LP and configure the interface based on MODE
if [ "$MODE" = "UNTAGGED" ]; then
    ssh $SSH_OPTIONS "$LP" << LP_EOF
        echo "Configuring LP interface for UNTAGGED mode..."
        ip addr add $CVL_INTF_IP dev $CVL_INTF
        ip link set $CVL_INTF up
        ip -br a
LP_EOF
elif [ "$MODE" = "VXLAN" ]; then
    ssh $SSH_OPTIONS "$LP" << LP_EOF
        echo "Configuring LP interface for VXLAN mode..."
        ip link add dev TEP10 type dummy
        ifconfig TEP10 10.1.1.2/24 up
        sleep 1
        # ip addr show TEP10
        # vxlan10 interface
        ip link add vxlan10 type vxlan id 10 dstport 4789 remote 10.1.1.1 local 10.1.1.2
        ip addr add 192.168.1.102/24 dev vxlan10
        ip link set vxlan10 up
        # ip addr show vxlan10
        ifconfig $CVL_INTF 1.1.1.2/24 up
        sleep 2
        # ip route change 10.1.1.0/24 via 1.1.1.1 dev $CVL_INTF
        # Attempt 'ip route change', if it fails, try 'ip route add'
        if ! ip route change 10.1.1.0/24 via 1.1.1.1 dev $CVL_INTF; then
            echo "ip route change failed, attempting ip route add..."
            ip route add 10.1.1.0/24 via 1.1.1.1 dev $CVL_INTF
        fi
        # ip addr show $CVL_INTF
        ip -br a
LP_EOF
else
    echo "Invalid MODE specified. Please use UNTAGGED or VXLAN."
    exit 1
fi
