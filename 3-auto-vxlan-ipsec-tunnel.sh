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
        echo "Removing old VXLAN interface config from LP..."
        ip addr del 10.1.1.2/24 dev TEP10 &>/dev/null
        ip addr del 192.168.1.102/24 dev vxlan10 &>/dev/null
        ip addr del 1.1.1.2/24 dev ens801f0 &>/dev/null
        ip link del vxlan10 &>/dev/null
        ip link del TEP10 &>/dev/null
        ip link del IPSECAPP &>/dev/null

        echo "Configuring LP interface for VXLAN mode..."
        ip link add dev TEP10 type dummy
        ifconfig TEP10 10.1.1.2/24 up
        sleep 1
        # vxlan10 interface
        ip link add vxlan10 type vxlan id 10 dstport 4789 remote 10.1.1.1 local 10.1.1.2
        ip addr add 192.168.1.102/24 dev vxlan10
        ip link set vxlan10 up
        ifconfig $CVL_INTF 1.1.1.2/24 up
        ip route add 1.1.1.0/24 dev $CVL_INTF # this should be auto-created, but sometimes doesnt - manually adding here
        sleep 2
        # Attempt 'ip route change', if it fails, try 'ip route add'
        if ! ip route change 10.1.1.0/24 via 1.1.1.1 dev $CVL_INTF; then
            echo "ip route change failed, attempting ip route add..."
            ip route add 10.1.1.0/24 via 1.1.1.1 dev $CVL_INTF
        fi
        
        # VXLAN + IPsec tunnel mode
        ip link add dev IPSECAPP type dummy
        ifconfig IPSECAPP 11.0.0.2/24 up
        sleep 3
        # Attempt 'ip route change', if it fails, try 'ip route add'
        if ! ip route change 11.0.0.0/24 dev vxlan10; then
            echo "ip route change failed, attempting ip route add..."
            ip route add 11.0.0.0/24 dev vxlan10
        fi

        ip -br a
LP_EOF
else
    echo "Invalid MODE specified. Please use UNTAGGED or VXLAN."
    exit 1
fi

echo ""
echo "====LP config complete==="
echo ""


# Configure IP address on Host and get VSI and MAC address for both interfaces
read VSI_HOST MAC_HOST VSI_IPSEC_APP MAC_IPSEC_APP < <(ssh $SSH_OPTIONS "$HOST" "
    # Configure IP address on the specified interface
    nmcli device set \"$HOST_VF_INTF\" managed no
    ip addr add $HOST_VF_IP dev $HOST_VF_INTF
    ip link set $HOST_VF_INTF up

    # Configure IP address on the IPSEC interface
    nmcli device set \"$IPSEC_VF_INTF\" managed no
    ip addr add $IPSEC_APP_HOST_IP dev $IPSEC_VF_INTF
    ip link set $IPSEC_VF_INTF up

    # Function to retrieve the MAC address and second byte
    $(declare -f get_mac_address)
    $(declare -f get_second_byte)

    # Get MAC address and VSI for HOST_VF_INTF
    MAC_ADDRESS=\$(get_mac_address $HOST_VF_INTF)
    VSI=\$(get_second_byte \$MAC_ADDRESS)

    # Get MAC address and VSI for IPSEC_VF_INTF
    IPSEC_MAC=\$(get_mac_address $IPSEC_VF_INTF)
    IPSEC_VSI=\$(get_second_byte \$IPSEC_MAC)

    # Output all values on a single line
    echo \$VSI \$MAC_ADDRESS \$IPSEC_VSI \$IPSEC_MAC
")

# Ensure VSI_HOST is not empty
if [ -z "$VSI_HOST" ] || [ -z "$VSI_IPSEC_APP" ]; then
    echo "Failed to retrieve VSI from Host interfaces."
    exit 1
fi


# Function to parse MAC address and remove colons
parse_mac_address_no_colons() {
    local mac_address=$1
    local mac_no_colons=$(echo "$mac_address" | tr -d ':')
    # mac_start, mac_mid, and mac_last are used in programming rif_mod_table
    # MAC=aa:bb:cc:dd:ee:ff => mac_start=aabb, mac_mid=ccdd, mac_last=eeff
    local mac_start=$(echo "$mac_no_colons" | cut -c1-4)
    local mac_mid=$(echo "$mac_no_colons" | cut -c5-8)
    local mac_last=$(echo "$mac_no_colons" | cut -c9-12)
    # dmac_high and dmac_low are used in programming nexthop_table
    # MAC=aa:bb:cc:dd:ee:ff => dmac_high=aabb, dmac_low=ccddeeff
    local dmac_high=$(echo "$mac_no_colons" | cut -c1-4)
    local dmac_low=$(echo "$mac_no_colons" | cut -c5-12)
    echo "$mac_no_colons $mac_start $mac_mid $mac_last $dmac_high $dmac_low"
}

# Get mac address details for rif mod_table programming
read MAC_HOST_NO_COLONS MAC_START MAC_MID MAC_LAST TMP1 TMP2 < <(parse_mac_address_no_colons "$MAC_HOST")

#echo "DEBUG: MAC_HOST=$MAC_HOST"
#echo "DEBUG: MAC_HOST_NO_COLONS=$MAC_HOST_NO_COLONS"
#echo "DEBUG: MAC_START=$MAC_START, MAC_MID=$MAC_MID, MAC_LAST=$MAC_LAST"

if [ -z "$MAC_START" ] || [ -z "$MAC_MID" ] || [ -z "$MAC_LAST" ]; then
    echo "Error: MAC address parts are empty. rif mod table entry programming might fail"
fi

# Get MAC address of vxlan10 interface from LP - for nexthop_table programming
VXLAN10_MAC=$(ssh $SSH_OPTIONS "$LP" "ip link show vxlan10 | awk '/ether/ {print \$2}'")
read VXLAN10_MAC_NO_COLONS TMP1 TMP2 TMP3 DMAC_HIGH DMAC_LOW < <(parse_mac_address_no_colons "$VXLAN10_MAC")

#echo "DEBUG: VXLAN10_MAC_NO_COLONS=$VXLAN10_MAC_NO_COLONS"
#echo "DEBUG: DMAC_HIGH=$DMAC_HIGH, DMAC_LOW=$DMAC_LOW"

if [ -z "$DMAC_HIGH" ] || [ -z "$DMAC_LOW" ]; then
    echo "Error: DMAC address parts are empty. nexthop_table entry programming might fail"
fi


# Use SSH ProxyCommand to connect to ACC through IMC
ssh $SSH_OPTIONS -o ProxyCommand="ssh $SSH_OPTIONS -W %h:%p $IMC" "$ACC" << EOF
    # Source the environment file
    source ~/setup_acc_env.sh
    
    # Function to retrieve the MAC address and second byte
    $(declare -f get_mac_address)
    $(declare -f get_second_byte)
    $(declare -f parse_mac_address_no_colons)

    # Get VSIs and MAC addresses from ACC
    MAC_ACC_PR1=\$(get_mac_address "$ACC_PR1_INTF")
    VSI_ACC_PR1=\$(get_second_byte "\$MAC_ACC_PR1")
    MAC_ACC_PR2=\$(get_mac_address "$ACC_PR2_INTF")
    VSI_ACC_PR2=\$(get_second_byte "\$MAC_ACC_PR2")
    MAC_ACC_PR3=\$(get_mac_address "$ACC_PR3_INTF")
    VSI_ACC_PR3=\$(get_second_byte "\$MAC_ACC_PR3")
    
    # Ensure VSI_ACC_PR1 and VSI_ACC_PR2 are not empty
    if [ -z "\$VSI_ACC_PR1" ] || [ -z "\$VSI_ACC_PR2" ] || [ -z "\$VSI_ACC_PR3" ]; then
        echo "Failed to retrieve VSI from ACC interfaces."
        exit 1
    fi
    
    # Convert VSI values to decimal
    HOST_VF_VSI=\$((0x$VSI_HOST))
    IPSEC_VF_VSI=\$((0x$VSI_IPSEC_APP))
    ACC_PR1_VSI=\$((0x\$VSI_ACC_PR1))
    ACC_PR2_VSI=\$((0x\$VSI_ACC_PR2))
    ACC_PR3_VSI=\$((0x\$VSI_ACC_PR3))
    
    # Port numbers (VSI+16)
    HOST_VF_PORT=\$((HOST_VF_VSI + 16))
    IPSEC_VF_PORT=\$((IPSEC_VF_VSI + 16))
    ACC_PR1_PORT=\$((ACC_PR1_VSI + 16))
    ACC_PR2_PORT=\$((ACC_PR2_VSI + 16))
    ACC_PR3_PORT=\$((ACC_PR3_VSI + 16))
    
    # Export the VSI & PORT values
    export HOST_VF_VSI HOST_VF_PORT
    export IPSEC_VF_VSI IPSEC_VF_PORT
    export ACC_PR1_VSI ACC_PR1_PORT
    export ACC_PR2_VSI ACC_PR2_PORT
    export ACC_PR3_VSI ACC_PR3_PORT

    echo "Running commands on ACC with VSI and PORT values..."
    echo "Host VF interface: $HOST_VF_INTF, MAC: $MAC_HOST, VSI: \$HOST_VF_VSI, Port: \$HOST_VF_PORT"
    echo "IPSEC VF interface: $IPSEC_VF_INTF, MAC: $MAC_IPSEC_APP, VSI: \$IPSEC_VF_VSI, Port: \$IPSEC_VF_PORT"
    echo "ACC PR1 interface: $ACC_PR1_INTF, MAC: \$MAC_ACC_PR1, VSI: \$ACC_PR1_VSI, Port: \$ACC_PR1_PORT"
    echo "ACC PR2 interface: $ACC_PR2_INTF, MAC: \$MAC_ACC_PR2, VSI: \$ACC_PR2_VSI, Port: \$ACC_PR2_PORT"
    echo "ACC PR3 interface: $ACC_PR3_INTF, MAC: \$MAC_ACC_PR3, VSI: \$ACC_PR3_VSI, Port: \$ACC_PR3_PORT"
    
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
    
    # VXLAN + IPsec tunnel mode
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.tx_source_port        "vmeta.common.vsi=\$IPSEC_VF_VSI/2047,priority=1,action=linux_networking_control.set_source_port(\$IPSEC_VF_PORT)"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.tx_acc_vsi            "vmeta.common.vsi=\$ACC_PR3_VSI,zero_padding=0,action=linux_networking_control.l2_fwd_and_bypass_bridge(\$IPSEC_VF_PORT)"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.vsi_to_vsi_loopback   "vmeta.common.vsi=\$ACC_PR3_VSI,target_vsi=\$IPSEC_VF_VSI,action=linux_networking_control.fwd_to_vsi(\$IPSEC_VF_PORT)"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.vsi_to_vsi_loopback   "vmeta.common.vsi=\$IPSEC_VF_VSI,target_vsi=\$ACC_PR3_VSI,action=linux_networking_control.fwd_to_vsi(\$ACC_PR3_PORT)"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.source_port_to_pr_map "user_meta.cmeta.source_port=\$IPSEC_VF_PORT,zero_padding=0,action=linux_networking_control.fwd_to_vsi(\$ACC_PR3_PORT)"

    ## 1. Add rif mod table entry
    # echo "MAC_HOST=$MAC_HOST, MAC_START=$MAC_START, MAC_MID=$MAC_MID, MAC_LAST=$MAC_LAST"

    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.rif_mod_table_start \
        "rif_mod_map_id0=0x0005,action=linux_networking_control.set_src_mac_start(arg=0x$MAC_START)"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.rif_mod_table_mid \
        "rif_mod_map_id1=0x0005,action=linux_networking_control.set_src_mac_mid(arg=0x$MAC_MID)"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.rif_mod_table_last \
        "rif_mod_map_id2=0x0005,action=linux_networking_control.set_src_mac_last(arg=0x$MAC_LAST)"
        
    ## 2. Add router interface to nexthop_table (get MAC address of vxlan10 interface from LP)
    # echo "vxlan10_MAC=$VXLAN10_MAC, vxlan10_MAC_no_colons=$VXLAN10_MAC_NO_COLONS, dmac_high=$DMAC_HIGH, dmac_low=$DMAC_LOW"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.nexthop_table \
        "user_meta.cmeta.nexthop_id=4,bit16_zeros=0,action=linux_networking_control.set_nexthop_info_dmac(router_interface_id=0x5,egress_port=0,dmac_high=0x$DMAC_HIGH,dmac_low=0x$DMAC_LOW)"

    ## 3. Add to ipv4_table (hardcode IP 192.168.1.102)
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.ipv4_table \
        "ipv4_table_lpm_root=0,ipv4_dst_match=0xc0a80166/24,action=linux_networking_control.ipv4_set_nexthop_id(nexthop_id=0x4)"


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
        ovs-vsctl add-port br-intrnl $ACC_PR3_INTF
        ifconfig br-intrnl up
        ovs-vsctl show
    elif [ "$MODE" = "VXLAN" ]; then
        echo "Adding OVS bridge and adding ports (VXLAN mode)..."
        ovs-vsctl add-br br-intrnl
        ovs-vsctl add-port br-intrnl $ACC_PR1_INTF
        ovs-vsctl add-port br-intrnl $ACC_PR3_INTF
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

