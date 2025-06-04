#!/bin/bash

<<COMMENT
            HOST                                    ACC                                                                                      Link Partner
============================      =====================================================================================                 =========================================

HOST_VF_INTF (ens801f0v0)------------------------PR------> ACC_PR1_INTF (enp0s1f0d4)
192.168.1.101                                                   |
                                                                |
                                                                |
IPSEC_VF_INTF (ens801f0v1)--PR---> ACC_PR3_INTF (enp0s1f0d6)    |
11.0.0.1                                                |       |       |---ACC_PR2_INTF (enp0s1f0d5)---PR--> PHY_PORT 0 ==================== ens801f0 ---------------IPSECAPP
                                                        |       |       |                                       |                             192.168.1.102             11.0.0.2
                                            ==================OVS================================
                                                br-intnl (enp0s1f0d4, enp0s1f0d5, enp0s1f0d6)


                                                br-intrnl-2 (enp0s1f0d7, enp0s1f0d8, enp0s1f0d9)
                                            =====================================================
                                                        |       |       |
                                                        |       |       |--ACC_PR5_INTF (enp0s1f0d8)---PR--> PHY_PORT 1 ==================== ens801f1 ---------------IPSECAPP_2
IPSEC_VF_INTF_2 (ens801f0v3)--PR---> ACC_PR6_INTF (enp0s1f0d9)  |                                                                            172.16.1.2                 22.0.0.2
22.0.0.1                                                        |
                                                                |
                                                                |
HOST_VF_INTF_2 (ens801f0v2)------------------------PR------> ACC_PR4_INTF (enp0s1f0d7)
172.16.1.1

COMMENT

# Source the environment file where IPs are defined
source ./config.env

echo "Starting 3-auto-dual-port-ipsec-tunnel.sh..."
echo "Note: No support for VXLAN. Mode in config.env is ignored in this script"

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

# SSH into LP and configure the interface for IPsec tunnel mode
ssh $SSH_OPTIONS "$LP" << LP_EOF
    echo "Configuring LP interface for IPsec tunnel mode..."
    ip addr add $CVL_INTF_IP dev $CVL_INTF
    ip link set $CVL_INTF up

    ip link add dev IPSECAPP type dummy
    ifconfig IPSECAPP $IPSEC_APP_LP_IP up
    sleep 3
    ip route replace 11.0.0.0/24 dev $CVL_INTF

    # Configure second CVL interface for dual port
    ip addr add $CVL_INTF_IP_2 dev $CVL_INTF_2
    ip link set $CVL_INTF_2 up

    ip link add dev IPSECAPP_2 type dummy
    ifconfig IPSECAPP_2 $IPSEC_APP_LP_IP_2 up
    sleep 3
    ip route replace 22.0.0.0/24 dev $CVL_INTF_2
    
    ip -br a
LP_EOF

echo ""
echo "====LP config complete==="
echo ""

# Configure IP addresses on Host and get VSI and MAC addresses for all interfaces
read VSI_HOST MAC_HOST VSI_IPSEC_APP MAC_IPSEC_APP VSI_HOST_2 MAC_HOST_2 VSI_IPSEC_APP_2 MAC_IPSEC_APP_2 < <(ssh $SSH_OPTIONS "$HOST" "
    # Configure IP address on the first set of interfaces
    nmcli device set \"$HOST_VF_INTF\" managed no
    ip addr add $HOST_VF_IP dev $HOST_VF_INTF
    ip link set $HOST_VF_INTF up

    # Configure IP address on the first IPSEC interface
    nmcli device set \"$IPSEC_VF_INTF\" managed no
    ip addr add $IPSEC_APP_HOST_IP dev $IPSEC_VF_INTF
    ip link set $IPSEC_VF_INTF up
    ip link set dev $IPSEC_VF_INTF mtu 1400

    # Configure IP address on the second set of interfaces
    nmcli device set \"$HOST_VF_INTF_2\" managed no
    ip addr add $HOST_VF_IP_2 dev $HOST_VF_INTF_2
    ip link set $HOST_VF_INTF_2 up

    # Configure IP address on the second IPSEC interface
    nmcli device set \"$IPSEC_VF_INTF_2\" managed no
    ip addr add $IPSEC_APP_HOST_IP_2 dev $IPSEC_VF_INTF_2
    ip link set $IPSEC_VF_INTF_2 up
    ip link set dev $IPSEC_VF_INTF_2 mtu 1400

    # Function to retrieve the MAC address and second byte
    $(declare -f get_mac_address)
    $(declare -f get_second_byte)

    # Get MAC address and VSI for first set
    MAC_ADDRESS=\$(get_mac_address $HOST_VF_INTF)
    VSI=\$(get_second_byte \$MAC_ADDRESS)
    IPSEC_MAC=\$(get_mac_address $IPSEC_VF_INTF)
    IPSEC_VSI=\$(get_second_byte \$IPSEC_MAC)

    # Get MAC address and VSI for second set
    MAC_ADDRESS_2=\$(get_mac_address $HOST_VF_INTF_2)
    VSI_2=\$(get_second_byte \$MAC_ADDRESS_2)
    IPSEC_MAC_2=\$(get_mac_address $IPSEC_VF_INTF_2)
    IPSEC_VSI_2=\$(get_second_byte \$IPSEC_MAC_2)

    # Output all values on a single line
    echo \$VSI \$MAC_ADDRESS \$IPSEC_VSI \$IPSEC_MAC \$VSI_2 \$MAC_ADDRESS_2 \$IPSEC_VSI_2 \$IPSEC_MAC_2
")

# Ensure all VSI values are not empty
if [ -z "$VSI_HOST" ] || [ -z "$VSI_IPSEC_APP" ] || [ -z "$VSI_HOST_2" ] || [ -z "$VSI_IPSEC_APP_2" ]; then
    echo "Failed to retrieve VSI from Host interfaces."
    exit 1
fi

# Function to parse MAC address and remove colons
parse_mac_address_no_colons() {
    local mac_address=$1
    local mac_no_colons=$(echo "$mac_address" | tr -d ':')
    local mac_start=$(echo "$mac_no_colons" | cut -c1-4)
    local mac_mid=$(echo "$mac_no_colons" | cut -c5-8)
    local mac_last=$(echo "$mac_no_colons" | cut -c9-12)
    local dmac_high=$(echo "$mac_no_colons" | cut -c1-4)
    local dmac_low=$(echo "$mac_no_colons" | cut -c5-12)
    echo "$mac_no_colons $mac_start $mac_mid $mac_last $dmac_high $dmac_low"
}

# Get mac address details for rif mod_table programming (first set)
read MAC_HOST_NO_COLONS MAC_START MAC_MID MAC_LAST TMP1 TMP2 < <(parse_mac_address_no_colons "$MAC_HOST")

# Get mac address details for rif mod_table programming (second set)
read MAC_HOST_NO_COLONS_2 MAC_START_2 MAC_MID_2 MAC_LAST_2 TMP3 TMP4 < <(parse_mac_address_no_colons "$MAC_HOST_2")

if [ -z "$MAC_START" ] || [ -z "$MAC_MID" ] || [ -z "$MAC_LAST" ] || [ -z "$MAC_START_2" ] || [ -z "$MAC_MID_2" ] || [ -z "$MAC_LAST_2" ]; then
    echo "Error: MAC address parts are empty. rif mod table entry programming might fail"
fi

# Get MAC addresses from LP for nexthop_table programming
CVL_INTF_MAC=$(ssh $SSH_OPTIONS "$LP" "ip link show $CVL_INTF | awk '/ether/ {print \$2}'")
read CVL_INTF_NO_COLONS TMP1 TMP2 TMP3 DMAC_HIGH DMAC_LOW < <(parse_mac_address_no_colons "$CVL_INTF_MAC")

CVL_INTF_MAC_2=$(ssh $SSH_OPTIONS "$LP" "ip link show $CVL_INTF_2 | awk '/ether/ {print \$2}'")
read CVL_INTF_NO_COLONS_2 TMP4 TMP5 TMP6 DMAC_HIGH_2 DMAC_LOW_2 < <(parse_mac_address_no_colons "$CVL_INTF_MAC_2")

if [ -z "$DMAC_HIGH" ] || [ -z "$DMAC_LOW" ] || [ -z "$DMAC_HIGH_2" ] || [ -z "$DMAC_LOW_2" ]; then
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
    MAC_ACC_PR4=\$(get_mac_address "$ACC_PR4_INTF")
    VSI_ACC_PR4=\$(get_second_byte "\$MAC_ACC_PR4")
    MAC_ACC_PR5=\$(get_mac_address "$ACC_PR5_INTF")
    VSI_ACC_PR5=\$(get_second_byte "\$MAC_ACC_PR5")
    MAC_ACC_PR6=\$(get_mac_address "$ACC_PR6_INTF")
    VSI_ACC_PR6=\$(get_second_byte "\$MAC_ACC_PR6")
    
    # Ensure all VSI values are not empty
    if [ -z "\$VSI_ACC_PR1" ] || [ -z "\$VSI_ACC_PR2" ] || [ -z "\$VSI_ACC_PR3" ] || [ -z "\$VSI_ACC_PR4" ] || [ -z "\$VSI_ACC_PR5" ] || [ -z "\$VSI_ACC_PR6" ]; then
        echo "Failed to retrieve VSI from ACC interfaces."
        exit 1
    fi
    
    # Convert VSI values to decimal
    HOST_VF_VSI=\$((0x$VSI_HOST))
    IPSEC_VF_VSI=\$((0x$VSI_IPSEC_APP))
    HOST_VF_VSI_2=\$((0x$VSI_HOST_2))
    IPSEC_VF_VSI_2=\$((0x$VSI_IPSEC_APP_2))
    ACC_PR1_VSI=\$((0x\$VSI_ACC_PR1))
    ACC_PR2_VSI=\$((0x\$VSI_ACC_PR2))
    ACC_PR3_VSI=\$((0x\$VSI_ACC_PR3))
    ACC_PR4_VSI=\$((0x\$VSI_ACC_PR4))
    ACC_PR5_VSI=\$((0x\$VSI_ACC_PR5))
    ACC_PR6_VSI=\$((0x\$VSI_ACC_PR6))
    
    # Port numbers (VSI+16)
    HOST_VF_PORT=\$((HOST_VF_VSI + 16))
    IPSEC_VF_PORT=\$((IPSEC_VF_VSI + 16))
    HOST_VF_PORT_2=\$((HOST_VF_VSI_2 + 16))
    IPSEC_VF_PORT_2=\$((IPSEC_VF_VSI_2 + 16))
    ACC_PR1_PORT=\$((ACC_PR1_VSI + 16))
    ACC_PR2_PORT=\$((ACC_PR2_VSI + 16))
    ACC_PR3_PORT=\$((ACC_PR3_VSI + 16))
    ACC_PR4_PORT=\$((ACC_PR4_VSI + 16))
    ACC_PR5_PORT=\$((ACC_PR5_VSI + 16))
    ACC_PR6_PORT=\$((ACC_PR6_VSI + 16))
    
    # Export the VSI & PORT values
    export HOST_VF_VSI HOST_VF_PORT HOST_VF_VSI_2 HOST_VF_PORT_2
    export IPSEC_VF_VSI IPSEC_VF_PORT IPSEC_VF_VSI_2 IPSEC_VF_PORT_2
    export ACC_PR1_VSI ACC_PR1_PORT ACC_PR2_VSI ACC_PR2_PORT ACC_PR3_VSI ACC_PR3_PORT
    export ACC_PR4_VSI ACC_PR4_PORT ACC_PR5_VSI ACC_PR5_PORT ACC_PR6_VSI ACC_PR6_PORT

    echo "Running commands on ACC with VSI and PORT values..."
    echo "First Port Set:"
    echo "Host VF interface: $HOST_VF_INTF, MAC: $MAC_HOST, VSI: \$HOST_VF_VSI, Port: \$HOST_VF_PORT"
    echo "IPSEC VF interface: $IPSEC_VF_INTF, MAC: $MAC_IPSEC_APP, VSI: \$IPSEC_VF_VSI, Port: \$IPSEC_VF_PORT"
    echo "ACC PR1 interface: $ACC_PR1_INTF, MAC: \$MAC_ACC_PR1, VSI: \$ACC_PR1_VSI, Port: \$ACC_PR1_PORT"
    echo "ACC PR2 interface: $ACC_PR2_INTF, MAC: \$MAC_ACC_PR2, VSI: \$ACC_PR2_VSI, Port: \$ACC_PR2_PORT"
    echo "ACC PR3 interface: $ACC_PR3_INTF, MAC: \$MAC_ACC_PR3, VSI: \$ACC_PR3_VSI, Port: \$ACC_PR3_PORT"
    echo ""
    echo "Second Port Set:"
    echo "Host VF interface 2: $HOST_VF_INTF_2, MAC: $MAC_HOST_2, VSI: \$HOST_VF_VSI_2, Port: \$HOST_VF_PORT_2"
    echo "IPSEC VF interface 2: $IPSEC_VF_INTF_2, MAC: $MAC_IPSEC_APP_2, VSI: \$IPSEC_VF_VSI_2, Port: \$IPSEC_VF_PORT_2"
    echo "ACC PR4 interface: $ACC_PR4_INTF, MAC: \$MAC_ACC_PR4, VSI: \$ACC_PR4_VSI, Port: \$ACC_PR4_PORT"
    echo "ACC PR5 interface: $ACC_PR5_INTF, MAC: \$MAC_ACC_PR5, VSI: \$ACC_PR5_VSI, Port: \$ACC_PR5_PORT"
    echo "ACC PR6 interface: $ACC_PR6_INTF, MAC: \$MAC_ACC_PR6, VSI: \$ACC_PR6_VSI, Port: \$ACC_PR6_PORT"
    
    # Add the P4 table programming commands
    echo "Programming P4 tables for first port set..."
    
    # First port set (existing configuration)
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.tx_source_port "vmeta.common.vsi=\$HOST_VF_VSI/2047,priority=1,action=linux_networking_control.set_source_port(\$HOST_VF_PORT)"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.tx_acc_vsi "vmeta.common.vsi=\$ACC_PR1_VSI,zero_padding=0,action=linux_networking_control.l2_fwd_and_bypass_bridge(\$HOST_VF_PORT)"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.vsi_to_vsi_loopback "vmeta.common.vsi=\$ACC_PR1_VSI,target_vsi=\$HOST_VF_VSI,action=linux_networking_control.fwd_to_vsi(\$HOST_VF_PORT)"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.vsi_to_vsi_loopback "vmeta.common.vsi=\$HOST_VF_VSI,target_vsi=\$ACC_PR1_VSI,action=linux_networking_control.fwd_to_vsi(\$ACC_PR1_PORT)"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.source_port_to_pr_map "user_meta.cmeta.source_port=\$HOST_VF_PORT,zero_padding=0,action=linux_networking_control.fwd_to_vsi(\$ACC_PR1_PORT)"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.rx_source_port "vmeta.common.port_id=$PHY_PORT,zero_padding=0,action=linux_networking_control.set_source_port($PHY_PORT)"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.rx_phy_port_to_pr_map "vmeta.common.port_id=$PHY_PORT,zero_padding=0,action=linux_networking_control.fwd_to_vsi(\$ACC_PR2_PORT)"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.source_port_to_pr_map "user_meta.cmeta.source_port=$PHY_PORT,zero_padding=0,action=linux_networking_control.fwd_to_vsi(\$ACC_PR2_PORT)"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.tx_acc_vsi "vmeta.common.vsi=\$ACC_PR2_VSI,zero_padding=0,action=linux_networking_control.l2_fwd_and_bypass_bridge($PHY_PORT)"
    
    # IPsec tunnel for first port
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.tx_source_port        "vmeta.common.vsi=\$IPSEC_VF_VSI/2047,priority=1,action=linux_networking_control.set_source_port(\$IPSEC_VF_PORT)"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.tx_acc_vsi            "vmeta.common.vsi=\$ACC_PR3_VSI,zero_padding=0,action=linux_networking_control.l2_fwd_and_bypass_bridge(\$IPSEC_VF_PORT)"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.vsi_to_vsi_loopback   "vmeta.common.vsi=\$ACC_PR3_VSI,target_vsi=\$IPSEC_VF_VSI,action=linux_networking_control.fwd_to_vsi(\$IPSEC_VF_PORT)"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.vsi_to_vsi_loopback   "vmeta.common.vsi=\$IPSEC_VF_VSI,target_vsi=\$ACC_PR3_VSI,action=linux_networking_control.fwd_to_vsi(\$ACC_PR3_PORT)"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.source_port_to_pr_map "user_meta.cmeta.source_port=\$IPSEC_VF_PORT,zero_padding=0,action=linux_networking_control.fwd_to_vsi(\$ACC_PR3_PORT)"

    echo "Programming P4 tables for second port set..."
    
    # Second port set (new configuration)
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.tx_source_port "vmeta.common.vsi=\$HOST_VF_VSI_2/2047,priority=1,action=linux_networking_control.set_source_port(\$HOST_VF_PORT_2)"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.tx_acc_vsi "vmeta.common.vsi=\$ACC_PR4_VSI,zero_padding=0,action=linux_networking_control.l2_fwd_and_bypass_bridge(\$HOST_VF_PORT_2)"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.vsi_to_vsi_loopback "vmeta.common.vsi=\$ACC_PR4_VSI,target_vsi=\$HOST_VF_VSI_2,action=linux_networking_control.fwd_to_vsi(\$HOST_VF_PORT_2)"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.vsi_to_vsi_loopback "vmeta.common.vsi=\$HOST_VF_VSI_2,target_vsi=\$ACC_PR4_VSI,action=linux_networking_control.fwd_to_vsi(\$ACC_PR4_PORT)"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.source_port_to_pr_map "user_meta.cmeta.source_port=\$HOST_VF_PORT_2,zero_padding=0,action=linux_networking_control.fwd_to_vsi(\$ACC_PR4_PORT)"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.rx_source_port "vmeta.common.port_id=$PHY_PORT_2,zero_padding=0,action=linux_networking_control.set_source_port($PHY_PORT_2)"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.rx_phy_port_to_pr_map "vmeta.common.port_id=$PHY_PORT_2,zero_padding=0,action=linux_networking_control.fwd_to_vsi(\$ACC_PR5_PORT)"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.source_port_to_pr_map "user_meta.cmeta.source_port=$PHY_PORT_2,zero_padding=0,action=linux_networking_control.fwd_to_vsi(\$ACC_PR5_PORT)"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.tx_acc_vsi "vmeta.common.vsi=\$ACC_PR5_VSI,zero_padding=0,action=linux_networking_control.l2_fwd_and_bypass_bridge($PHY_PORT_2)"
    
    # IPsec tunnel for second port
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.tx_source_port        "vmeta.common.vsi=\$IPSEC_VF_VSI_2/2047,priority=1,action=linux_networking_control.set_source_port(\$IPSEC_VF_PORT_2)"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.tx_acc_vsi            "vmeta.common.vsi=\$ACC_PR6_VSI,zero_padding=0,action=linux_networking_control.l2_fwd_and_bypass_bridge(\$IPSEC_VF_PORT_2)"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.vsi_to_vsi_loopback   "vmeta.common.vsi=\$ACC_PR6_VSI,target_vsi=\$IPSEC_VF_VSI_2,action=linux_networking_control.fwd_to_vsi(\$IPSEC_VF_PORT_2)"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.vsi_to_vsi_loopback   "vmeta.common.vsi=\$IPSEC_VF_VSI_2,target_vsi=\$ACC_PR6_VSI,action=linux_networking_control.fwd_to_vsi(\$ACC_PR6_PORT)"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.source_port_to_pr_map "user_meta.cmeta.source_port=\$IPSEC_VF_PORT_2,zero_padding=0,action=linux_networking_control.fwd_to_vsi(\$ACC_PR6_PORT)"

    # Common P4 table entries
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.ipv4_lpm_root_lut "user_meta.cmeta.bit16_zeros=4/65535,priority=2048,action=linux_networking_control.ipv4_lpm_root_lut_action(0)"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=0/7,priority=1,action=linux_networking_control.bypass"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=1/7,priority=1,action=linux_networking_control.bypass"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=2/7,priority=1,action=linux_networking_control.bypass"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=3/7,priority=1,action=linux_networking_control.bypass"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=4/7,priority=1,action=linux_networking_control.bypass"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=5/7,priority=1,action=linux_networking_control.bypass"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=6/7,priority=1,action=linux_networking_control.bypass"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=7/7,priority=1,action=linux_networking_control.bypass"

    # RIF mod table entries for both ports
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.rif_mod_table_start \
        "rif_mod_map_id0=0x0005,action=linux_networking_control.set_src_mac_start(arg=0x$MAC_START)"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.rif_mod_table_mid \
        "rif_mod_map_id1=0x0005,action=linux_networking_control.set_src_mac_mid(arg=0x$MAC_MID)"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.rif_mod_table_last \
        "rif_mod_map_id2=0x0005,action=linux_networking_control.set_src_mac_last(arg=0x$MAC_LAST)"

    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.rif_mod_table_start \
        "rif_mod_map_id0=0x0006,action=linux_networking_control.set_src_mac_start(arg=0x$MAC_START_2)"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.rif_mod_table_mid \
        "rif_mod_map_id1=0x0006,action=linux_networking_control.set_src_mac_mid(arg=0x$MAC_MID_2)"
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.rif_mod_table_last \
        "rif_mod_map_id2=0x0006,action=linux_networking_control.set_src_mac_last(arg=0x$MAC_LAST_2)"

    # Add router interface to nexthop_table for first port
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.nexthop_table \
        "user_meta.cmeta.nexthop_id=4,bit16_zeros=0,action=linux_networking_control.set_nexthop_info_dmac(router_interface_id=0x5,egress_port=0,dmac_high=0x$DMAC_HIGH,dmac_low=0x$DMAC_LOW)"

    # Add router interface to nexthop_table for second port
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.nexthop_table \
        "user_meta.cmeta.nexthop_id=8,bit16_zeros=0,action=linux_networking_control.set_nexthop_info_dmac(router_interface_id=0x6,egress_port=1,dmac_high=0x$DMAC_HIGH_2,dmac_low=0x$DMAC_LOW_2)"

    ## 3. Add to ipv4_table (hardcode IP 192.168.1.102)
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.ipv4_table \
        "ipv4_table_lpm_root=0,ipv4_dst_match=0xc0a80166/24,action=linux_networking_control.ipv4_set_nexthop_id(nexthop_id=0x4)"

    # Add to ipv4_table for second port (hardcode IP 172.16.1.2)
    \$P4RT_CTL_CMD add-entry br0 linux_networking_control.ipv4_table \
        "ipv4_table_lpm_root=0,ipv4_dst_match=0xac100102/24,action=linux_networking_control.ipv4_set_nexthop_id(nexthop_id=0x8)"

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
    --log-file=/tmp/logs/ovs-vswitchd.log --grpc-addr="$GRPC_ADDR_IP"
    ovs-vsctl set Open_vSwitch . other_config:n-revalidator-threads=1
    ovs-vsctl set Open_vSwitch . other_config:n-handler-threads=1
    
    echo "Adding OVS bridge and adding ports for dual port IPsec tunnel mode..."
    
    # Create first bridge for first port set
    ovs-vsctl add-br br-intrnl
    ovs-vsctl add-port br-intrnl $ACC_PR1_INTF
    ovs-vsctl add-port br-intrnl $ACC_PR2_INTF
    ovs-vsctl add-port br-intrnl $ACC_PR3_INTF
    ifconfig br-intrnl up
    
    # Create second bridge for second port set
    ovs-vsctl add-br br-intrnl-2
    ovs-vsctl add-port br-intrnl-2 $ACC_PR4_INTF
    ovs-vsctl add-port br-intrnl-2 $ACC_PR5_INTF
    ovs-vsctl add-port br-intrnl-2 $ACC_PR6_INTF
    ifconfig br-intrnl-2 up
       
    ovs-vsctl show
EOF
