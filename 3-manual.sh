
    |----------Host-----------------------------------------------------------------|
    |                                                                               |
    |  HOST_VF_INTF = 192.168.1.101/24                                              |
    |  (ens801f0v0)                                                                 |
    |  (VSI 0x1C)                                                                   |
    |       |               -----------------------ACC-------------------           |
    |       |               |                                           |           |
    |       |               |       |==========OVS===========|          |           |
    |       |               |       |                        |          |           |
    |       |               |   ACC_PR1_INTF            ACC_PR2_INTF    |           |
    |       |               |   (enp0s1f0d4)            (enp0s1f0d5)    |           |
    |       |---------------|---(VSI 0x0B)              (VSI 0x0C)      |           |
    |                       |                               |           |           |
    |                       |-------------------------------|-----------|           |           
    |                                                       |                       |
    |                                                       |---------------->PHY_PORT 0  <==============> LP ens801f0 = 192.168.1.102/24
    |-------------------------------------------------------------------------------|


HOST_VF_INTF=ens801f0v0; HOST_VF_VSI=28 ; HOST_VF_PORT=44
ACC_PR1_INTF=enp0s1f0d4 ;  ACC_PR1_VSI=11  ; ACC_PR1_PORT=27

echo "HOST_VF - ACC_PR1:"
echo "HOST_VF_INTF | 0x1c(28)   | 0x2c(44)   | ${HOST_VF_INTF} | 00:1c:00:00:03:14 |"
echo "ACC_PR1_INTF | 0x0B(11)   | 0x1B(27)   | ${ACC_PR1_INTF} | 00:0b:00:04:03:18 |"
 
 
p4rt-ctl add-entry br0 linux_networking_control.tx_source_port_v4     "vmeta.common.vsi=${HOST_VF_VSI}/2047,priority=1,action=linux_networking_control.set_source_port(${HOST_VF_PORT})"
p4rt-ctl add-entry br0 linux_networking_control.tx_acc_vsi            "vmeta.common.vsi=${ACC_PR1_VSI},zero_padding=0,action=linux_networking_control.l2_fwd_and_bypass_bridge(${HOST_VF_PORT})"
p4rt-ctl add-entry br0 linux_networking_control.vsi_to_vsi_loopback   "vmeta.common.vsi=${ACC_PR1_VSI},target_vsi=${HOST_VF_VSI},action=linux_networking_control.fwd_to_vsi(${HOST_VF_PORT})"
p4rt-ctl add-entry br0 linux_networking_control.vsi_to_vsi_loopback   "vmeta.common.vsi=${HOST_VF_VSI},target_vsi=${ACC_PR1_VSI},action=linux_networking_control.fwd_to_vsi(${ACC_PR1_PORT})"
p4rt-ctl add-entry br0 linux_networking_control.source_port_to_pr_map "user_meta.cmeta.source_port=${HOST_VF_PORT},zero_padding=0,action=linux_networking_control.fwd_to_vsi(${ACC_PR1_PORT})"

 
ACC_PR2_INTF=enp0s1f0d5  ; ACC_PR2_VSI=12  ; ACC_PR2_PORT=28
PHY_PORT=0

echo "ACC_PR2 - PHY_PORT:"
echo "ACC_PR2_INTF | 0x0C(12)   | 0x1C(28)   | ${ACC_PR2_INTF} | 00:0c:00:05:03:18 |"
echo "ACC_P0  | PHY_PORT=${PHY_PORT}"
 
p4rt-ctl add-entry br0 linux_networking_control.rx_source_port         "vmeta.common.port_id=${PHY_PORT},zero_padding=0,action=linux_networking_control.set_source_port(${PHY_PORT})"
p4rt-ctl add-entry br0 linux_networking_control.rx_phy_port_to_pr_map  "vmeta.common.port_id=${PHY_PORT},zero_padding=0,action=linux_networking_control.fwd_to_vsi(${ACC_PR2_PORT})"
p4rt-ctl add-entry br0 linux_networking_control.source_port_to_pr_map  "user_meta.cmeta.source_port=${PHY_PORT},zero_padding=0,action=linux_networking_control.fwd_to_vsi(${ACC_PR2_PORT})"
p4rt-ctl add-entry br0 linux_networking_control.tx_acc_vsi             "vmeta.common.vsi=${ACC_PR2_VSI},zero_padding=0,action=linux_networking_control.l2_fwd_and_bypass_bridge(${PHY_PORT})"

p4rt-ctl add-entry br0 linux_networking_control.ipv4_lpm_root_lut "user_meta.cmeta.bit16_zeros=4/65535,priority=2048,action=linux_networking_control.ipv4_lpm_root_lut_action(0)"
 
p4rt-ctl add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=0/7,priority=1,action=linux_networking_control.bypass"
p4rt-ctl add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=1/7,priority=1,action=linux_networking_control.bypass"
p4rt-ctl add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=2/7,priority=1,action=linux_networking_control.bypass"
p4rt-ctl add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=3/7,priority=1,action=linux_networking_control.bypass"
p4rt-ctl add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=4/7,priority=1,action=linux_networking_control.bypass"
p4rt-ctl add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=5/7,priority=1,action=linux_networking_control.bypass"
p4rt-ctl add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=6/7,priority=1,action=linux_networking_control.bypass"
p4rt-ctl add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=7/7,priority=1,action=linux_networking_control.bypass"



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


ovs-vsctl add-br br-intrnl
ovs-vsctl add-port br-intrnl enp0s1f0d4
ovs-vsctl add-port br-intrnl enp0s1f0d5
ifconfig br-intrnl up
ovs-vsctl show

# On LP
#======
ip addr add dev ens801f0 192.168.1.102/24


# Cleanup previous bridge
# ====================

ifconfig br-intrnl down
ovs-vsctl del-port br-intrnl enp0s1f0d5
ovs-vsctl del-port br-intrnl enp0s1f0d4
ovs-vsctl del-br br-intrnl
ovs-vsctl show

# On LP
# ====
ip addr del dev ens801f0 192.168.1.102/24



# Setup br-intrnl
# ===============
ovs-vsctl add-br br-intrnl
ovs-vsctl add-port br-intrnl enp0s1f0d4
ovs-vsctl add-port br-intrnl vxlan1 -- set interface vxlan1 type=vxlan \
    options:local_ip=10.1.1.1 options:remote_ip=10.1.1.2 options:key=10 options:dst_port=4789
ifconfig br-intrnl up
sleep 1

# Setup br-tunl
# =============
ovs-vsctl add-br br-tunl
ovs-vsctl add-port br-tunl enp0s1f0d5
ifconfig br-tunl 1.1.1.1/24 up
sleep 1

ip link add dev TEP10 type dummy
sleep 1
ifconfig TEP10 10.1.1.1/24 up
ip route change 10.1.1.0/24 via 1.1.1.2 dev br-tunl


# On LP
# =====

ip xfrm state deleteall
ip xfrm policy deleteall

CVL_INTF=ens801f0

ip link add dev TEP10 type dummy
ifconfig TEP10 10.1.1.2/24 up
sleep 1
ip addr show TEP10

# vxlan10 interface
ip link add vxlan10 type vxlan id 10 dstport 4789 remote 10.1.1.1 local 10.1.1.2
ip addr add 192.168.1.102/24 dev vxlan10
ip link set vxlan10 up
ip addr show vxlan10

ifconfig ${CVL_INTF} 1.1.1.2/24 up
ip route change 10.1.1.0/24 via 1.1.1.1 dev ${CVL_INTF}
ip addr show ${CVL_INTF}



# Cleanup LP
# ==========

ip addr del 10.1.1.2/24 dev TEP10
ip addr del 192.168.1.102/24 dev vxlan10
ip addr del 1.1.1.2/24 dev ens801f0
ip link del vxlan10
ip link del TEP10





======
IPsec (manual config)
======


#
# Add routing interface and add to nextop table
#
# HOST_VF
# ens801f0v0 : 00:1c:00:00:03:14
 
p4rt-ctl add-entry br0 linux_networking_control.rif_mod_table_start \
    "rif_mod_map_id0=0x0005,action=linux_networking_control.set_src_mac_start(arg=0x001c)"
p4rt-ctl add-entry br0 linux_networking_control.rif_mod_table_mid \
    "rif_mod_map_id1=0x0005,action=linux_networking_control.set_src_mac_mid(arg=0x0000)"
p4rt-ctl add-entry br0 linux_networking_control.rif_mod_table_last \
    "rif_mod_map_id2=0x0005,action=linux_networking_control.set_src_mac_last(arg=0x0314)"
 
# table nexthop_table - Add router interface (0x05)
 
#${P4_DEL_ENTRY} linux_networking_control.nexthop_table "user_meta.cmeta.nexthop_id=4,bit16_zeros=0"
 
# CVL_HOST - nexthop
# vxlan10 (xx.102) : ee:35:eb:f9:2f:2b
p4rt-ctl add-entry br0 linux_networking_control.nexthop_table \
    "user_meta.cmeta.nexthop_id=4,bit16_zeros=0,action=linux_networking_control.set_nexthop_info_dmac(router_interface_id=0x5,egress_port=0,dmac_high=0xee35,dmac_low=0xebf92f2b)"
 
# Add to ipv4_table
p4rt-ctl add-entry br0 linux_networking_control.ipv4_table \
    "ipv4_table_lpm_root=0,ipv4_dst_match=0xc0a80166/24,action=linux_networking_control.ipv4_set_nexthop_id(nexthop_id=0x4)"







=====
VXLAN (below IPv6 config does NOT work)
=====

ifconfig br-intrnl down
ovs-vsctl del-port br-intrnl enp0s1f0d5
ovs-vsctl del-port br-intrnl enp0s1f0d4
ovs-vsctl del-br br-intrnl
ovs-vsctl show


ovs-vsctl add-br br-intrnl
ovs-vsctl add-port br-intrnl enp0s1f0d4
ovs-vsctl add-port br-intrnl vxlan1 -- set interface vxlan1 type=vxlan \
    options:local_ip=1000:1::1 options:remote_ip=1000:1::2 options:key=10 options:dst_port=4789
ifconfig br-intrnl up
sleep 1

ovs-vsctl add-br br-tunl
ovs-vsctl add-port br-tunl enp0s1f0d5
ip addr add 5::1/64 dev br-tunl
ip link set br-tunl up
sleep 1

ip link add dev TEP10 type dummy
sleep 1
ip addr add 1000:1::1/64 dev TEP10
ip link set TEP10 up
ip route add 1000:1::/64 via 5::2 dev br-tunl


Host
===
ip addr add dev ens801f0v1 9::1/64

LP
==
CVL_INTF=ens801f0

ip link add dev TEP10 type dummy
ip addr add 1000:1::2/64 dev TEP10
ip link set TEP10 up
ip addr show TEP10

# vxlan10 interface
ip link add vxlan10 type vxlan id 10 dstport 4789 remote 1000:1::2 local 1000:1::1
ip addr add 9::2/64 dev vxlan10
ip link set vxlan10 up
ip addr show vxlan10

ip addr add 5::2/64 dev ${CVL_INTF}
ip link set ${CVL_INTF} up
ip route add 1000:1::/64 via 5::1 dev ${CVL_INTF}
ip addr show ${CVL_INTF}
