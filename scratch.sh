#!/bin/bash

IMC="root@100.0.0.100"
ACC="root@192.168.0.2"
HOST="root@10.166.232.1"
setup_network() {
    HOST_VF_INTF=$1
    HOST_VF_VSI=28
    HOST_VF_PORT=44
    ACC_PR1_INTF="enp0s1f0d4"
    ACC_PR1_VSI=11
    ACC_PR1_PORT=27
    ACC_PR2_INTF="enp0s1f0d5"
    ACC_PR2_VSI=12
    ACC_PR2_PORT=28
    PHY_PORT=0

    echo "HOST_VF - ACC_PR1:"
    echo "HOST_VF_INTF | 0x1c(28)   | 0x2c(44)   | $HOST_VF_INTF | 00:1c:00:00:03:14 |"
    echo "ACC_PR1_INTF | 0x0B(11)   | 0x1B(27)   | $ACC_PR1_INTF | 00:0b:00:04:03:18 |"

    echo "ACC_PR2 - PHY_PORT:"
    echo "ACC_PR2_INTF | 0x0C(12)   | 0x1C(28)   | $ACC_PR2_INTF | 00:0c:00:05:03:18 |"
    echo "ACC_P0  | PHY_PORT=0"

    /opt/p4/p4-cp-nws/bin/p4rt-ctl -g 10.10.0.2:9559  add-entry br0 linux_networking_control.tx_source_port_v4     "vmeta.common.vsi=$(printf '%d' $HOST_VF_VSI)/2047,priority=1,action=linux_networking_control.set_source_port($(printf '%d' $HOST_VF_PORT))"
    /opt/p4/p4-cp-nws/bin/p4rt-ctl -g 10.10.0.2:9559  add-entry br0 linux_networking_control.tx_acc_vsi            "vmeta.common.vsi=$(printf '%d' $ACC_PR1_VSI),zero_padding=0,action=linux_networking_control.l2_fwd_and_bypass_bridge($(printf '%d' $HOST_VF_PORT))"
    /opt/p4/p4-cp-nws/bin/p4rt-ctl -g 10.10.0.2:9559  add-entry br0 linux_networking_control.vsi_to_vsi_loopback   "vmeta.common.vsi=$(printf '%d' $ACC_PR1_VSI),target_vsi=$(printf '%d' $HOST_VF_VSI),action=linux_networking_control.fwd_to_vsi($(printf '%d' $HOST_VF_PORT))"
    /opt/p4/p4-cp-nws/bin/p4rt-ctl -g 10.10.0.2:9559  add-entry br0 linux_networking_control.vsi_to_vsi_loopback   "vmeta.common.vsi=$(printf '%d' $HOST_VF_VSI),target_vsi=$(printf '%d' $ACC_PR1_VSI),action=linux_networking_control.fwd_to_vsi($(printf '%d' $ACC_PR1_PORT))"
    /opt/p4/p4-cp-nws/bin/p4rt-ctl -g 10.10.0.2:9559  add-entry br0 linux_networking_control.source_port_to_pr_map "user_meta.cmeta.source_port=$(printf '%d' $HOST_VF_PORT),zero_padding=0,action=linux_networking_control.fwd_to_vsi($(printf '%d' $ACC_PR1_PORT))"
   
    /opt/p4/p4-cp-nws/bin/p4rt-ctl -g 10.10.0.2:9559  add-entry br0 linux_networking_control.rx_source_port         "vmeta.common.port_id=$(printf '%d' $PHY_PORT),zero_padding=0,action=linux_networking_control.set_source_port($(printf '%d' $PHY_PORT))"
    /opt/p4/p4-cp-nws/bin/p4rt-ctl -g 10.10.0.2:9559  add-entry br0 linux_networking_control.rx_phy_port_to_pr_map  "vmeta.common.port_id=$(printf '%d' $PHY_PORT),zero_padding=0,action=linux_networking_control.fwd_to_vsi($(printf '%d' $ACC_PR2_PORT))"
    /opt/p4/p4-cp-nws/bin/p4rt-ctl -g 10.10.0.2:9559  add-entry br0 linux_networking_control.source_port_to_pr_map  "user_meta.cmeta.source_port=$(printf '%d' $PHY_PORT),zero_padding=0,action=linux_networking_control.fwd_to_vsi($(printf '%d' $ACC_PR2_PORT))"
    /opt/p4/p4-cp-nws/bin/p4rt-ctl -g 10.10.0.2:9559  add-entry br0 linux_networking_control.tx_acc_vsi             "vmeta.common.vsi=$(printf '%d' $ACC_PR2_VSI),zero_padding=0,action=linux_networking_control.l2_fwd_and_bypass_bridge(0)"

    /opt/p4/p4-cp-nws/bin/p4rt-ctl -g 10.10.0.2:9559  add-entry br0 linux_networking_control.ipv4_lpm_root_lut "user_meta.cmeta.bit16_zeros=4/65535,priority=2048,action=linux_networking_control.ipv4_lpm_root_lut_action(0)"
    
    /opt/p4/p4-cp-nws/bin/p4rt-ctl -g 10.10.0.2:9559  add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=0/7,priority=1,action=linux_networking_control.bypass"
    /opt/p4/p4-cp-nws/bin/p4rt-ctl -g 10.10.0.2:9559  add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=1/7,priority=1,action=linux_networking_control.bypass"
    /opt/p4/p4-cp-nws/bin/p4rt-ctl -g 10.10.0.2:9559  add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=2/7,priority=1,action=linux_networking_control.bypass"
    /opt/p4/p4-cp-nws/bin/p4rt-ctl -g 10.10.0.2:9559  add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=3/7,priority=1,action=linux_networking_control.bypass"
    /opt/p4/p4-cp-nws/bin/p4rt-ctl -g 10.10.0.2:9559  add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=4/7,priority=1,action=linux_networking_control.bypass"
    /opt/p4/p4-cp-nws/bin/p4rt-ctl -g 10.10.0.2:9559  add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=5/7,priority=1,action=linux_networking_control.bypass"
    /opt/p4/p4-cp-nws/bin/p4rt-ctl -g 10.10.0.2:9559  add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=6/7,priority=1,action=linux_networking_control.bypass"
    /opt/p4/p4-cp-nws/bin/p4rt-ctl -g 10.10.0.2:9559  add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=7/7,priority=1,action=linux_networking_control.bypass"


    nmcli device set enp0s1f0d4 managed no
    nmcli device set enp0s1f0d5 managed no
}

start_ovs() {
    printf "Starting OVS..."
    export RUN_OVS=/opt/p4/p4-cp-nws

    pkill -9 ovsdb-server
    pkill -9 ovsdb-vswitchd
    rm -rf $RUN_OVS/etc/openvswitch
    rm -rf $RUN_OVS/var/run/openvswitch
    mkdir -p $RUN_OVS/etc/openvswitch/
    mkdir -p $RUN_OVS/var/run/openvswitch
    ovsdb-tool create $RUN_OVS/etc/openvswitch/conf.db \
            $RUN_OVS/share/openvswitch/vswitch.ovsschema
    ovsdb-server \
            --remote=punix:$RUN_OVS/var/run/openvswitch/db.sock \
            --remote=db:Open_vSwitch,Open_vSwitch,manager_options \
            --pidfile --detach
    ovs-vsctl --no-wait init
    mkdir -p /tmp/logs
    ovs-vswitchd --pidfile --detach --mlockall \
            --log-file=/tmp/logs/ovs-vswitchd.log --grpc-addr="10.10.0.2"
    ovs-vsctl set Open_vSwitch . other_config:n-revalidator-threads=1
    ovs-vsctl set Open_vSwitch . other_config:n-handler-threads=1
    ovs-vsctl  show

    printf "Configuring OVS bridge..."
    sleep 1
    
    ovs-vsctl add-br br-intrnl
    ovs-vsctl add-port br-intrnl enp0s1f0d4
    ovs-vsctl add-port br-intrnl enp0s1f0d5
    ifconfig br-intrnl up
    ovs-vsctl show

}



ssh "$IMC" << EOF
    # SSH to ACC from IMC
    ssh "$ACC" << REMOTE
$(typeset -f setup_network)
#$(typeset -f start_ovs)

setup_network
#start_ovs
REMOTE
EOF
