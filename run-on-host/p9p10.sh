
export SDE=/root/sabeel/p4-sde
cd $SDE/p4_sde-nat-p4-driver/tools/setup
source $SDE/p4_sde-nat-p4-driver/tools/setup/p4sde_env_setup.sh $SDE
export DEPEND_INSTALL=/root/sabeel/stratum-deps/install
export P4CP_RECIPE=/root/sabeel/networking-recipe
export P4CP_INSTALL=/root/sabeel/networking-recipe/install
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$DEPEND_INSTALL/lib:$DEPEND_INSTALL/lib64
export PATH=$P4CP_INSTALL/bin:$P4CP_INSTALL/sbin:$PATH
export OUTPUT_DIR=/usr/share/stratum/lnw-v3
export RUN_OVS=$P4CP_RECIPE/ovs/install


infrap4d
p4rt-ctl set-pipe br0 $OUTPUT_DIR/lnw-v3.pb.bin $OUTPUT_DIR/p4Info.txt

modprobe idpf
echo 4 > /sys/class/net/ens801f0/device/sriov_numvfs


ens801f0         UP             00:01:00:00:03:14 <BROADCAST,MULTICAST,UP,LOWER_UP>
ens801f0d1       UP             00:18:00:01:03:14 <BROADCAST,MULTICAST,UP,LOWER_UP> -> OVERLAY PR
ens801f0d2       UP             00:19:00:02:03:14 <BROADCAST,MULTICAST,UP,LOWER_UP> -> P0 PR
ens801f0d3       UP             00:1a:00:03:03:14 <BROADCAST,MULTICAST,UP,LOWER_UP> -> P1 PR
ens801f0v0       UP             00:1b:00:00:03:14 <BROADCAST,MULTICAST,UP,LOWER_UP> -> OVERLAY VF
ens801f0v2       UP             00:1c:00:00:03:14 <BROADCAST,MULTICAST,UP,LOWER_UP>
ens801f0v1       UP             00:1d:00:00:03:14 <BROADCAST,MULTICAST,UP,LOWER_UP>
ens801f0v3       UP             00:1e:00:00:03:14 <BROADCAST,MULTICAST,UP,LOWER_UP>


=======================


ens801f0v0 (0x1b, 27) <==> ens801f0d1 (0x18, 24)

Phy port 0            <==> ens801f0d2 (0x19, 25)
Phy port 1            <==> ens801f0d3 (0x1a, 26)


OVERLAY_VF_INTF=ens801f0v0; OVERLAY_VF_VSI=27; OVERLAY_VF_PORT=43
OVERLAY_PR_INTF=ens801f0d1; OVERLAY_PR_VSI=24; OVERLAY_PR_PORT=40
PHY_PORT_0=0
PHY_PORT_1=1
PR0_INTF=ens801f0d2; PR0_VSI=25; PR0_PORT=41
PR1_INTF=ens801f0d3; PR1_VSI=26; PR1_PORT=42


#phy port to SRC port
p4rt-ctl add-entry br0 linux_networking_control.rx_source_port "vmeta.common.port_id=0,zero_padding=0,action=linux_networking_control.set_source_port(0)"
p4rt-ctl add-entry br0 linux_networking_control.rx_source_port "vmeta.common.port_id=1,zero_padding=0,action=linux_networking_control.set_source_port(1)"
 
#HOST port to SRC port IPv4 ( VSI + 16)
p4rt-ctl add-entry br0 linux_networking_control.tx_source_port_v4 "vmeta.common.vsi=${OVERLAY_VF_VSI}/2047,priority=1,action=linux_networking_control.set_source_port(${OVERLAY_VF_PORT})"

#ACC to HOST or wire
p4rt-ctl add-entry br0 linux_networking_control.tx_acc_vsi "vmeta.common.vsi=${OVERLAY_PR_VSI},zero_padding=0,action=linux_networking_control.l2_fwd_and_bypass_bridge(${OVERLAY_VF_PORT})"
p4rt-ctl add-entry br0 linux_networking_control.tx_acc_vsi "vmeta.common.vsi=${PR0_VSI},zero_padding=0,action=linux_networking_control.l2_fwd_and_bypass_bridge(0)"
p4rt-ctl add-entry br0 linux_networking_control.tx_acc_vsi "vmeta.common.vsi=${PR1_VSI},zero_padding=0,action=linux_networking_control.l2_fwd_and_bypass_bridge(1)"
 
#VSI to VSI
p4rt-ctl add-entry br0 linux_networking_control.vsi_to_vsi_loopback "vmeta.common.vsi=${OVERLAY_VF_VSI},target_vsi=${OVERLAY_PR_VSI},action=linux_networking_control.fwd_to_vsi(${OVERLAY_PR_PORT})"
p4rt-ctl add-entry br0 linux_networking_control.vsi_to_vsi_loopback "vmeta.common.vsi=${OVERLAY_PR_VSI},target_vsi=${OVERLAY_VF_VSI},action=linux_networking_control.fwd_to_vsi(${OVERLAY_VF_PORT})"

#SRC port to PR
p4rt-ctl add-entry br0 linux_networking_control.source_port_to_pr_map "user_meta.cmeta.source_port=${OVERLAY_VF_PORT},zero_padding=0,action=linux_networking_control.fwd_to_vsi(${OVERLAY_PR_PORT})"
p4rt-ctl add-entry br0 linux_networking_control.source_port_to_pr_map "user_meta.cmeta.source_port=0,zero_padding=0,action=linux_networking_control.fwd_to_vsi(${PR0_PORT})"
p4rt-ctl add-entry br0 linux_networking_control.source_port_to_pr_map "user_meta.cmeta.source_port=1,zero_padding=0,action=linux_networking_control.fwd_to_vsi(${PR1_PORT})"
 
#Phy port to PR
p4rt-ctl add-entry br0 linux_networking_control.rx_phy_port_to_pr_map "vmeta.common.port_id=0,zero_padding=0,action=linux_networking_control.fwd_to_vsi(${PR0_PORT})"
p4rt-ctl add-entry br0 linux_networking_control.rx_phy_port_to_pr_map "vmeta.common.port_id=1,zero_padding=0,action=linux_networking_control.fwd_to_vsi(${PR1_PORT})"


p4rt-ctl add-entry br0 linux_networking_control.source_port_to_bridge_map "user_meta.cmeta.source_port=0/0xffff,hdrs.vlan_ext[vmeta.common.depth].hdr.vid=0/0xfff,priority=1,action=linux_networking_control.set_bridge_id(0)"
p4rt-ctl add-entry br0 linux_networking_control.source_port_to_bridge_map "user_meta.cmeta.source_port=1/0xffff,hdrs.vlan_ext[vmeta.common.depth].hdr.vid=0/0xfff,priority=1,action=linux_networking_control.set_bridge_id(0)"


#LUT
p4rt-ctl add-entry br0 linux_networking_control.ipv4_lpm_root_lut "user_meta.cmeta.bit16_zeros=4/65535,priority=2048,action=linux_networking_control.ipv4_lpm_root_lut_action(0)" 

#p4rt-ctl add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=0/7,priority=1,action=linux_networking_control.bypass"
#p4rt-ctl add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=1/7,priority=1,action=linux_networking_control.bypass"
#p4rt-ctl add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=2/7,priority=1,action=linux_networking_control.bypass"
#p4rt-ctl add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=3/7,priority=1,action=linux_networking_control.bypass"
#p4rt-ctl add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=4/7,priority=1,action=linux_networking_control.bypass"
#p4rt-ctl add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=5/7,priority=1,action=linux_networking_control.bypass"
#p4rt-ctl add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=6/7,priority=1,action=linux_networking_control.bypass"
#p4rt-ctl add-entry br0 linux_networking_control.tx_lag_table "user_meta.cmeta.lag_group_id=0/255,hash=7/7,priority=1,action=linux_networking_control.bypass"

p4rt-ctl dump-entries br0


# OVS
# ===

rm -rf $RUN_OVS/etc/openvswitch
rm -rf $RUN_OVS/var/run/openvswitch 
mkdir -p $RUN_OVS/etc/openvswitch/
mkdir -p $RUN_OVS/var/run/openvswitch
$RUN_OVS/bin/ovsdb-tool create $RUN_OVS/etc/openvswitch/conf.db $RUN_OVS/share/openvswitch/vswitch.ovsschema
$RUN_OVS/sbin/ovsdb-server $RUN_OVS/etc/openvswitch/conf.db  --remote=punix:$RUN_OVS/var/run/openvswitch/db.sock  --remote=db:Open_vSwitch,Open_vSwitch,manager_options  --pidfile=$RUN_OVS/var/run/openvswitch/ovsdb-server.pid --unixctl=$RUN_OVS/var/run/openvswitch/ovsdb-server.ctl --detach
$P4CP_RECIPE/install/sbin/ovs-vswitchd --detach --pidfile=$RUN_OVS/var/run/openvswitch/ovs-vswitchd.pid --no-chdir unix:$RUN_OVS/var/run/openvswitch/db.sock --unixctl=$RUN_OVS/var/run/openvswitch/ovs-vswitchd.ctl --mlockall --log-file=/tmp/ovs-vswitchd.log
$P4CP_RECIPE/ovs/install/bin/ovs-vsctl --db unix:$RUN_OVS/var/run/openvswitch/db.sock show
alias ovs-vsctl="$P4CP_RECIPE/ovs/install/bin/ovs-vsctl --db unix:$RUN_OVS/var/run/openvswitch/db.sock"
ovs-vsctl set Open_vSwitch . other_config:n-revalidator-threads=1
ovs-vsctl set Open_vSwitch . other_config:n-handler-threads=1
ovs-vsctl  show



ovs-vsctl add-br br-intrnl
ovs-vsctl add-port br-intrnl ${OVERLAY_PR_INTF}
ovs-vsctl add-port br-intrnl ${PR0_INTF}
ifconfig br-intrnl up
ovs-vsctl show

ip addr add dev ${HOST_VF_INTF} 9.9.9.1/24


==================

WORKS!


        ----------------------HOST----------------
        |     ens801f0d2 = 9.9.9.1/24           |
        |               PR2_VSI                 |
        |                   |                   |
        --------------------|-------------------
                            |-------------------------->PHY_PORT 0  <==============> LP ens801f0 9.9.9.2/24




ACC_PR2_INTF=ens801f0d2 
ACC_PR2_VSI=25 
PHY_PORT=0

p4rt-ctl add-entry br0 linux_networking_control.rx_source_port         "vmeta.common.port_id=${PHY_PORT},zero_padding=0,action=linux_networking_control.set_source_port(${PHY_PORT})"
p4rt-ctl add-entry br0 linux_networking_control.rx_phy_port_to_pr_map  "vmeta.common.port_id=${PHY_PORT},zero_padding=0,action=linux_networking_control.fwd_to_vsi($((ACC_PR2_VSI+16)))"
p4rt-ctl add-entry br0 linux_networking_control.source_port_to_pr_map  "user_meta.cmeta.source_port=${PHY_PORT},zero_padding=0,action=linux_networking_control.fwd_to_vsi($((ACC_PR2_VSI+16)))"
p4rt-ctl add-entry br0 linux_networking_control.tx_acc_vsi             "vmeta.common.vsi=${ACC_PR2_VSI},zero_padding=0,action=linux_networking_control.l2_fwd_and_bypass_bridge(0)"
p4rt-ctl add-entry br0 linux_networking_control.source_port_to_bridge_map "user_meta.cmeta.source_port=0/0xffff,hdrs.vlan_ext[vmeta.common.depth].hdr.vid=0/0xfff,priority=1,action=linux_networking_control.set_bridge_id(0)"


ip addr add dev ${ACC_PR2_INTF} 9.9.9.1/24

ping 9.9.9.2


On LP
=====
ip addr add dev ens801f0 9.9.9.2/24


