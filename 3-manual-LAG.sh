

            HOST                                    ACC                                                                                      Link Partner
============================          ==================================================                                            ============================

HOST_VF_INTF (ens801f0v0)----------PR------> ACC_PR1_INTF (enp0s1f0d4)--------------
    VSI (0x1C)                                      VSI (0x0B)                          
192.168.1.102/24                                        |
                                                        |
                                                        |                           
                                                  =====OVS===============
                                                    br-intrnl
                                                  ======================
                                                                                                            
                                                        
                                                        |---------------|
                                                        |               |---- ACC_PR2_INTF (enp0s1f0d5)-----PR----> PHY_PORT 0 ==================== ens801f0--------|
                                                       bond0                      VSI (0x0C)                                                                        |
                                                        |                                                                                                           bond0 (40.1.1.2)-----vxlan1
                                                        |                                                                                                           |                      192.168.1.102/24
                                                        ----------------------ACC_PR3_INTF (enp0s1f0d6)-----PR-----> PHY_PORT_1 ==================== ens801f1-------|                                                                          |
                                                                            VSI (0x0D)
                                                                                                                                         







# On host
#=========
nmcli device set ens801f0v0 managed no
ip addr add dev ens801f0v0 192.168.1.101/24


# LAG config on LP
#=================
ip link add bond0 type bond miimon 100 mode 802.3ad lacp_rate fast

CVL_INTF_0=ens801f0
CVL_INTF_1=ens801f1


ip link set ${CVL_INTF_0} down
ip link set ${CVL_INTF_0} master bond0
ip link set ${CVL_INTF_1} down
ip link set ${CVL_INTF_1} master bond0
ip link set bond0 up
ifconfig bond0 40.1.1.2/24 up

ip link add vxlan1 type vxlan id 10 dstport 4789 remote 40.1.1.1 local 40.1.1.2 dev bond0
ip addr add 192.168.1.102/24 dev vxlan1
ip link set vxlan1 up



# On ACC
#=========
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
ACC_PR3_INTF=enp0s1f0d6  ; ACC_PR3_VSI=13  ; ACC_PR3_PORT=29
PHY_PORT_1=1

echo "ACC_PR2 - PHY_PORT_0:"
echo "ACC_PR2_INTF | 0x0C(12)   | 0x1C(28)   | ${ACC_PR2_INTF} | 00:0c:00:05:03:18 |"
echo "ACC_P0  | PHY_PORT_0=${PHY_PORT_0}"
echo "ACC_PR3 - PHY_PORT_1:"
echo "ACC_PR3_INTF | 0x0D(13)   | 0x13(29)   | ${ACC_PR3_INTF} | 00:0d:00:05:03:18 |"
echo "ACC_P1  | PHY_PORT_1=${PHY_PORT_1}"
 

p4rt-ctl add-entry br0 linux_networking_control.rx_source_port         "vmeta.common.port_id=${PHY_PORT_0},zero_padding=0,action=linux_networking_control.set_source_port(${PHY_PORT_0})"
p4rt-ctl add-entry br0 linux_networking_control.rx_phy_port_to_pr_map  "vmeta.common.port_id=${PHY_PORT_0},zero_padding=0,action=linux_networking_control.fwd_to_vsi(${ACC_PR2_PORT})"
p4rt-ctl add-entry br0 linux_networking_control.source_port_to_pr_map  "user_meta.cmeta.source_port=${PHY_PORT_0},zero_padding=0,action=linux_networking_control.fwd_to_vsi(${ACC_PR2_PORT})"
p4rt-ctl add-entry br0 linux_networking_control.tx_acc_vsi             "vmeta.common.vsi=${ACC_PR2_VSI},zero_padding=0,action=linux_networking_control.l2_fwd_and_bypass_bridge(${PHY_PORT_0})"

p4rt-ctl add-entry br0 linux_networking_control.rx_source_port         "vmeta.common.port_id=${PHY_PORT_1},zero_padding=0,action=linux_networking_control.set_source_port(${PHY_PORT_1})"
p4rt-ctl add-entry br0 linux_networking_control.rx_phy_port_to_pr_map  "vmeta.common.port_id=${PHY_PORT_1},zero_padding=0,action=linux_networking_control.fwd_to_vsi(${ACC_PR3_PORT})"
p4rt-ctl add-entry br0 linux_networking_control.source_port_to_pr_map  "user_meta.cmeta.source_port=${PHY_PORT_1},zero_padding=0,action=linux_networking_control.fwd_to_vsi(${ACC_PR3_PORT})"
p4rt-ctl add-entry br0 linux_networking_control.tx_acc_vsi             "vmeta.common.vsi=${ACC_PR3_VSI},zero_padding=0,action=linux_networking_control.l2_fwd_and_bypass_bridge(${PHY_PORT_1})"

p4rt-ctl add-entry br0 linux_networking_control.ipv4_lpm_root_lut "user_meta.cmeta.bit16_zeros=4/65535,priority=2048,action=linux_networking_control.ipv4_lpm_root_lut_action(0)"

# source_port_to_bridge_map (for LAG scenario)
p4rt-ctl add-entry br0 linux_networking_control.source_port_to_bridge_map \
     "user_meta.cmeta.source_port=0/0xffff,hdrs.vlan_ext[vmeta.common.depth].hdr.vid=0/0xfff,priority=1,action=linux_networking_control.set_bridge_id(0)"
 p4rt-ctl add-entry br0 linux_networking_control.source_port_to_bridge_map \
     "user_meta.cmeta.source_port=1/0xffff,hdrs.vlan_ext[vmeta.common.depth].hdr.vid=0/0xfff,priority=1,action=linux_networking_control.set_bridge_id(0)"


# LAG config on ACC
#===================

systemctl stop NetworkManager

ip link add bond0 type bond miimon 100 mode 802.3ad lacp_rate fast
ip link set ${ACC_PR2_INTF} down
ip link set ${ACC_PR2_INTF} master bond0
ip link set ${ACC_PR3_INTF} down
ip link set ${ACC_PR3_INTF} master bond0
ip link set bond0 up
ifconfig bond0 40.1.1.1/24 up
ip route change 40.1.1.0/24 via 40.1.1.2 dev bond0





## OVS config
# ============

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

# VXLAN
# ======

ovs-vsctl add-br br-1
ovs-vsctl add-port br-1 enp0s1f0d4
ovs-vsctl add-port br-1 vxlan1 -- set interface vxlan1  type=vxlan \
    options:local_ip=40.1.1.1 options:remote_ip=40.1.1.2 options:key=10 options:dst_port=4789






# Cleanup
#============


ip link set bond0 down
ip link del bond0


