

            HOST                                    ACC                                                                                      Link Partner
============================          ==================================================                                            ============================

HOST_VF_INTF (ens801f0v0)----------PR------> ACC_PR1_INTF (enp0s1f0d4)--------------
    VSI (0x1C)                                      VSI (0x0B)                          
192.168.1.102/24                                        |
                                                        |
                                                        |                  |---- ACC_PR2_INTF -----PR----> PHY_PORT 0 =============== ens801f0         TEP10             vxlan10
                                                        |                  |      (enp0s1f0d5)                                        1.1.1.2 --------- 10.1.1.2 ----- 192.168.1.102
                                                        |                  |        (0x0C)                                                                                       
                                                  ======|=========OVS======|=========
                                                    br-intrnl-------------br-tunl--
                                                (TEP/vxlan 10.1.1.1)    (1.1.1.1)


                                                    br-intrnl2-----------br-tunl2--
                                                (TEP/vxlan 20.2.2.1)      (2.2.2.1)
                                                  ======|==================|==========
                                                        |                  |                                                                                                     
HOST_VF2_INTF (ens801f0v1)---------PR-------> ACC_PR3_INTF (enp0s1f0d6)    |-----ACC_PR4_INTF ----PR----> PHY_PORT 1 ================ ens801f1          TEP20           vxlan20
    VSI (0x1D)                                      VSI (0x0D)                   (enp0s1f0d7)                                         2.2.2.2 -------- 20.2.2.2 ------ 11.0.0.2
   11.0.0.1/24                                                                     (0x0E)                                                                                        




# On LP
# =====

ip xfrm state deleteall
ip xfrm policy deleteall

CVL_INTF_P0=ens801f0
CVL_INTF_P1=ens801f1

## Port 0

ip link add dev TEP10 type dummy
ifconfig TEP10 10.1.1.2/24 up
sleep 1

# vxlan10 interface
ip link add vxlan10 type vxlan id 10 dstport 4789 remote 10.1.1.1 local 10.1.1.2
ip addr add 192.168.1.102/24 dev vxlan10
ip link set vxlan10 up

ifconfig ${CVL_INTF_P0} 1.1.1.2/24 up
sleep 2
ip route change 10.1.1.0/24 via 1.1.1.1 dev ${CVL_INTF_P0}
ip route add 1.1.1.0/24 dev $CVL_INTF_P0 # this should be auto-created, but sometimes doesnt - manually adding here
ip route change 10.1.1.0/24 via 1.1.1.1 dev $CVL_INTF_P0 # if this fails, use 'ip route add' instead


## Port 1

ip link add dev TEP20 type dummy
ifconfig TEP20 20.2.2.2/24 up
sleep 1

# vxlan20 interface
ip link add vxlan20 type vxlan id 20 dstport 4789 remote 20.2.2.1 local 20.2.2.2
ip addr add 11.0.0.2/24 dev vxlan20
ip link set vxlan20 up

ifconfig ${CVL_INTF_P1} 2.2.2.2/24 up
sleep 2
ip route change 20.2.2.0/24 via 2.2.2.2 dev ${CVL_INTF_P1}
ip route add 2.2.2.0/24 dev $CVL_INTF_P1 # this should be auto-created, but sometimes doesnt - manually adding here
ip route change 20.2.2.0/24 via 2.2.2.2 dev $CVL_INTF_P1 # if this fails, use 'ip route add' instead


######


# On ACC
# ======

HOST_VF_INTF=ens801f0v0 ; HOST_VF_VSI=28 ; HOST_VF_PORT=44
ACC_PR1_INTF=enp0s1f0d4 ; ACC_PR1_VSI=11 ; ACC_PR1_PORT=27

echo "HOST_VF - ACC_PR1:"
echo "HOST_VF_INTF | 0x1c(28)   | 0x2c(44)   | ${HOST_VF_INTF} | 00:1c:00:00:03:14 |"
echo "ACC_PR1_INTF | 0x0B(11)   | 0x1B(27)   | ${ACC_PR1_INTF} | 00:0b:00:04:03:18 |"
 
p4rt-ctl add-entry br0 linux_networking_control.tx_source_port        "vmeta.common.vsi=${HOST_VF_VSI}/2047,priority=1,action=linux_networking_control.set_source_port(${HOST_VF_PORT})"
p4rt-ctl add-entry br0 linux_networking_control.tx_acc_vsi            "vmeta.common.vsi=${ACC_PR1_VSI},zero_padding=0,action=linux_networking_control.l2_fwd_and_bypass_bridge(${HOST_VF_PORT})"
p4rt-ctl add-entry br0 linux_networking_control.vsi_to_vsi_loopback   "vmeta.common.vsi=${ACC_PR1_VSI},target_vsi=${HOST_VF_VSI},action=linux_networking_control.fwd_to_vsi(${HOST_VF_PORT})"
p4rt-ctl add-entry br0 linux_networking_control.vsi_to_vsi_loopback   "vmeta.common.vsi=${HOST_VF_VSI},target_vsi=${ACC_PR1_VSI},action=linux_networking_control.fwd_to_vsi(${ACC_PR1_PORT})"
p4rt-ctl add-entry br0 linux_networking_control.source_port_to_pr_map "user_meta.cmeta.source_port=${HOST_VF_PORT},zero_padding=0,action=linux_networking_control.fwd_to_vsi(${ACC_PR1_PORT})"

 
ACC_PR2_INTF=enp0s1f0d5  ; ACC_PR2_VSI=12  ; ACC_PR2_PORT=28
PHY_PORT_0=0

echo "ACC_PR2 - PHY_PORT_0:"
echo "ACC_PR2_INTF | 0x0C(12)   | 0x1C(28)   | ${ACC_PR2_INTF} | 00:0f:00:05:03:18 |"
echo "ACC_P0  | PHY_PORT_0=${PHY_PORT_0}"
 
p4rt-ctl add-entry br0 linux_networking_control.rx_source_port         "vmeta.common.port_id=${PHY_PORT_0},zero_padding=0,action=linux_networking_control.set_source_port(${PHY_PORT_0})"
p4rt-ctl add-entry br0 linux_networking_control.rx_phy_port_to_pr_map  "vmeta.common.port_id=${PHY_PORT_0},zero_padding=0,action=linux_networking_control.fwd_to_vsi(${ACC_PR2_PORT})"
p4rt-ctl add-entry br0 linux_networking_control.source_port_to_pr_map  "user_meta.cmeta.source_port=${PHY_PORT_0},zero_padding=0,action=linux_networking_control.fwd_to_vsi(${ACC_PR2_PORT})"
p4rt-ctl add-entry br0 linux_networking_control.tx_acc_vsi             "vmeta.common.vsi=${ACC_PR2_VSI},zero_padding=0,action=linux_networking_control.l2_fwd_and_bypass_bridge(${PHY_PORT_0})"



# For Host_VF2_INTF

HOST_VF2_INTF=ens801f0v1 ; HOST_VF2_VSI=29 ; HOST_VF2_PORT=45
ACC_PR3_INTF=enp0s1f0d6 ; ACC_PR3_VSI=13 ; ACC_PR3_PORT=29

echo "HOST_VF2 - ACC_PR3:"
echo "HOST_VF2_INTF | 0x1d(29)   | 0x2d(45)   | ${HOST_VF2_INTF} | 00:1d:00:00:03:14 |"
echo "ACC_PR3_VSI   | 0x0d(13)   | 0x1D(29)   | ${ACC_PR3_INTF}  | 00:0d:00:04:03:18 |"
 
p4rt-ctl add-entry br0 linux_networking_control.tx_source_port        "vmeta.common.vsi=${HOST_VF2_VSI}/2047,priority=1,action=linux_networking_control.set_source_port(${HOST_VF2_PORT})"
p4rt-ctl add-entry br0 linux_networking_control.tx_acc_vsi            "vmeta.common.vsi=${ACC_PR3_VSI},zero_padding=0,action=linux_networking_control.l2_fwd_and_bypass_bridge(${HOST_VF2_PORT})"
p4rt-ctl add-entry br0 linux_networking_control.vsi_to_vsi_loopback   "vmeta.common.vsi=${ACC_PR3_VSI},target_vsi=${HOST_VF2_VSI},action=linux_networking_control.fwd_to_vsi(${HOST_VF2_PORT})"
p4rt-ctl add-entry br0 linux_networking_control.vsi_to_vsi_loopback   "vmeta.common.vsi=${HOST_VF2_VSI},target_vsi=${ACC_PR3_VSI},action=linux_networking_control.fwd_to_vsi(${ACC_PR3_PORT})"
p4rt-ctl add-entry br0 linux_networking_control.source_port_to_pr_map "user_meta.cmeta.source_port=${HOST_VF2_PORT},zero_padding=0,action=linux_networking_control.fwd_to_vsi(${ACC_PR3_PORT})"

ACC_PR4_INTF=enp0s1f0d7  ; ACC_PR4_VSI=14  ; ACC_PR4_PORT=30
PHY_PORT_1=1

echo "ACC_PR4 - PHY_PORT_1:"
echo "ACC_PR4_INTF | 0x0E(14)   | 0x1E(230)   | ${ACC_PR4_INTF} | 00:0e:00:07:03:18 |"
echo "ACC_P1  | PHY_PORT_1=${PHY_PORT_1}"
 
p4rt-ctl add-entry br0 linux_networking_control.rx_source_port         "vmeta.common.port_id=${PHY_PORT_1},zero_padding=0,action=linux_networking_control.set_source_port(${PHY_PORT_1})"
p4rt-ctl add-entry br0 linux_networking_control.rx_phy_port_to_pr_map  "vmeta.common.port_id=${PHY_PORT_1},zero_padding=0,action=linux_networking_control.fwd_to_vsi(${ACC_PR4_PORT})"
p4rt-ctl add-entry br0 linux_networking_control.source_port_to_pr_map  "user_meta.cmeta.source_port=${PHY_PORT_1},zero_padding=0,action=linux_networking_control.fwd_to_vsi(${ACC_PR4_PORT})"
p4rt-ctl add-entry br0 linux_networking_control.tx_acc_vsi             "vmeta.common.vsi=${ACC_PR4_VSI},zero_padding=0,action=linux_networking_control.l2_fwd_and_bypass_bridge(${PHY_PORT_1})"


# Add LPM and dummy LAG rules
p4rt-ctl add-entry br0 linux_networking_control.ipv4_lpm_root_lut "user_meta.cmeta.bit16_zeros=4/65535,priority=2048,action=linux_networking_control.ipv4_lpm_root_lut_action(0)"
 
p4rt-ctl add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=0/7,priority=1,action=linux_networking_control.bypass"
p4rt-ctl add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=1/7,priority=1,action=linux_networking_control.bypass"
p4rt-ctl add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=2/7,priority=1,action=linux_networking_control.bypass"
p4rt-ctl add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=3/7,priority=1,action=linux_networking_control.bypass"
p4rt-ctl add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=4/7,priority=1,action=linux_networking_control.bypass"
p4rt-ctl add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=5/7,priority=1,action=linux_networking_control.bypass"
p4rt-ctl add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=6/7,priority=1,action=linux_networking_control.bypass"
p4rt-ctl add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=7/7,priority=1,action=linux_networking_control.bypass"

# Add routing interface and add to nextop table

# HOST_VF_INTF : ens801f0v0 : 00:1c:00:00:03:14 <-- 192.168.1.101 MAC address
 
p4rt-ctl add-entry br0 linux_networking_control.rif_mod_table_start \
    "rif_mod_map_id0=0x0005,action=linux_networking_control.set_src_mac_start(arg=0x001c)"
p4rt-ctl add-entry br0 linux_networking_control.rif_mod_table_mid \
    "rif_mod_map_id1=0x0005,action=linux_networking_control.set_src_mac_mid(arg=0x0000)"
p4rt-ctl add-entry br0 linux_networking_control.rif_mod_table_last \
    "rif_mod_map_id2=0x0005,action=linux_networking_control.set_src_mac_last(arg=0x0314)"
 
# table nexthop_table - Add router interface (0x05)
 
# CVL_HOST - nexthop - use LP's 192.168.1.102 interface MAC address
# if running non-vxlan, this will be the ens801f0 (phy) mac address. if using vxlan tunneling, this should be the vxlan10 MAC address
# ens801f0         UP             6c:fe:54:47:44:70 <-- LP MAC 192.168.1.102                                                               
# vxlan10          UP             ee:35:eb:f9:2f:2b <-- LP vxlan10 MAC address for 192.168.1.102
p4rt-ctl add-entry br0 linux_networking_control.nexthop_table \
    "user_meta.cmeta.nexthop_id=4,bit16_zeros=0,action=linux_networking_control.set_nexthop_info_dmac(router_interface_id=0x5,egress_port=0,dmac_high=0xee35,dmac_low=0xebf92f2b)"
 
# Add to ipv4_table <-- entry for IPsec tunnel routing lookup
# dst_match=0xc0a80166 = 192.168.1.102
p4rt-ctl add-entry br0 linux_networking_control.ipv4_table \
    "ipv4_table_lpm_root=0,ipv4_dst_match=0xc0a80166/24,action=linux_networking_control.ipv4_set_nexthop_id(nexthop_id=0x4)"



# HOST_VF2_INTF : ens801f0v1 : 00:1d:00:00:03:14 <-- 11.0.0.1 MAC address
 
p4rt-ctl add-entry br0 linux_networking_control.rif_mod_table_start \
    "rif_mod_map_id0=0x0007,action=linux_networking_control.set_src_mac_start(arg=0x001d)"
p4rt-ctl add-entry br0 linux_networking_control.rif_mod_table_mid \
    "rif_mod_map_id1=0x0007,action=linux_networking_control.set_src_mac_mid(arg=0x0000)"
p4rt-ctl add-entry br0 linux_networking_control.rif_mod_table_last \
    "rif_mod_map_id2=0x0007,action=linux_networking_control.set_src_mac_last(arg=0x0314)"
 
# table nexthop_table - Add router interface (0x07)
 
# CVL_HOST - nexthop - use LP's 11.0.0.2 interface MAC address
# if running non-vxlan, this will be the ens801f1 (phy) mac address. if using vxlan tunneling, this should be the vxlan20 MAC address
# ens801f1         UP             6c:fe:54:47:44:71 <-- LP MAC 11.0.0.2                                                               
# vxlan20          UP             5e:56:f4:65:2f:a5 <-- LP vxlan20 MAC address for 11.0.0.2
p4rt-ctl add-entry br0 linux_networking_control.nexthop_table \
    "user_meta.cmeta.nexthop_id=8,bit16_zeros=0,action=linux_networking_control.set_nexthop_info_dmac(router_interface_id=0x7,egress_port=1,dmac_high=0x5e56,dmac_low=0xf4652fa5)"
 
# Add to ipv4_table <-- entry for IPsec tunnel routing lookup
# dst_match=0x0b000002 = 11.0.0.2
p4rt-ctl add-entry br0 linux_networking_control.ipv4_table \
    "ipv4_table_lpm_root=0,ipv4_dst_match=0x0b000002/24,action=linux_networking_control.ipv4_set_nexthop_id(nexthop_id=0x8)"


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
sleep 2
ip route replace 10.1.1.0/24 via 1.1.1.2 dev br-tunl


# Setup br-intrnl2
# ================
ovs-vsctl add-br br-intrnl2
ovs-vsctl add-port br-intrnl2 enp0s1f0d6
ovs-vsctl add-port br-intrnl2 vxlan2 -- set interface vxlan2 type=vxlan \
    options:local_ip=20.2.2.1 options:remote_ip=20.2.2.2 options:key=20 options:dst_port=4789
ifconfig br-intrnl2 up
sleep 1

# Setup br-tunl2
# ==============
ovs-vsctl add-br br-tunl2
ovs-vsctl add-port br-tunl2 enp0s1f0d7
ifconfig br-tunl2 2.2.2.1/24 up
sleep 1

ip link add dev TEP20 type dummy
sleep 1
ifconfig TEP20 20.2.2.1/24 up
sleep 2
ip route replace 20.2.2.0/24 via 2.2.2.2 dev br-tunl2


# On Host
# =======
nmcli device set ens801f0v0 managed no
nmcli device set ens801f0v1 managed no

ip addr add dev ens801f0v0 192.168.1.101/24
ip addr add dev ens801f0v1 11.0.0.1/24


# Cleanup LP
# ==========

ip addr del 10.1.1.2/24 dev TEP10
ip addr del 192.168.1.102/24 dev vxlan10
ip addr del 1.1.1.2/24 dev ens801f0
ip link del vxlan10
ip link del TEP10

ip addr del 20.2.2.2/24 dev TEP20
ip addr del 11.0.0.2/24 dev vxlan20
ip addr del 2.2.2.2/24 dev ens801f1
ip link del vxlan20
ip link del TEP20
