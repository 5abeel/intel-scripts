

        ACC                                                                                      Link Partner
==================================================                                            ============================

    enp0s1f0d8
    VSI (0x11) 192.168.1.101/24
        |
        |

    ACC_PR1_INTF (enp0s1f0d4)
    VSI (0x0B)
        |
        |
        |                         
    ================OVS================
        br-intrnl-------------br-tunl--
    (TEP/vxlan 10.1.1.1)    (1.1.1.1)
    =========================|=========
                             |
                             |---- ACC_PR2_INTF -----PR----> PHY_PORT 0 ====================== ens801f0         TEP10             vxlan10
                                    (enp0s1f0d5)                                               1.1.1.2 --------- 10.1.1.2 ----- 192.168.1.102
                                    (0x0C)                                                                                       



# On LP
# =====

ip xfrm state deleteall
ip xfrm policy deleteall

CVL_INTF=ens801f0

ip link add dev TEP10 type dummy
ifconfig TEP10 10.1.1.2/24 up
sleep 1

# vxlan10 interface
ip link add vxlan10 type vxlan id 10 dstport 4789 remote 10.1.1.1 local 10.1.1.2
ip addr add 192.168.1.102/24 dev vxlan10
ip link set vxlan10 up

ifconfig ${CVL_INTF} 1.1.1.2/24 up
sleep 2
ip route change 10.1.1.0/24 via 1.1.1.1 dev ${CVL_INTF}
ip route add 1.1.1.0/24 dev $CVL_INTF # this should be auto-created, but sometimes doesnt - manually adding here
ip route change 10.1.1.0/24 via 1.1.1.1 dev $CVL_INTF # if this fails, use 'ip route add' instead

ip link add dev IPSECAPP type dummy
ifconfig IPSECAPP 11.0.0.2/24 up
ip route change 11.0.0.0/24 dev vxlan10 # if this fails, use 'ip route add' instead


# For VXLAN + IPsec tunnel mode --> need to set IPSECAPP interface to lower MTU size
# On LP
ip link set dev IPSECAPP mtu 1400


# On ACC
# ======

HOST_VF_INTF=enp0s1f0d8 ; HOST_VF_VSI=17 ; HOST_VF_PORT=33
ACC_PR1_INTF=enp0s1f0d4 ; ACC_PR1_VSI=13 ; ACC_PR1_PORT=29

p4rt-ctl add-entry br0 linux_networking_control.tx_source_port        "vmeta.common.vsi=${HOST_VF_VSI}/2047,priority=1,action=linux_networking_control.set_source_port(${HOST_VF_PORT})"
p4rt-ctl add-entry br0 linux_networking_control.tx_acc_vsi            "vmeta.common.vsi=${ACC_PR1_VSI},zero_padding=0,action=linux_networking_control.l2_fwd_and_bypass_bridge(${HOST_VF_PORT})"
p4rt-ctl add-entry br0 linux_networking_control.vsi_to_vsi_loopback   "vmeta.common.vsi=${ACC_PR1_VSI},target_vsi=${HOST_VF_VSI},action=linux_networking_control.fwd_to_vsi(${HOST_VF_PORT})"
p4rt-ctl add-entry br0 linux_networking_control.vsi_to_vsi_loopback   "vmeta.common.vsi=${HOST_VF_VSI},target_vsi=${ACC_PR1_VSI},action=linux_networking_control.fwd_to_vsi(${ACC_PR1_PORT})"
p4rt-ctl add-entry br0 linux_networking_control.source_port_to_pr_map "user_meta.cmeta.source_port=${HOST_VF_PORT},zero_padding=0,action=linux_networking_control.fwd_to_vsi(${ACC_PR1_PORT})"

 
ACC_PR2_INTF=enp0s1f0d5  ; ACC_PR2_VSI=14  ; ACC_PR2_PORT=30
PHY_PORT=0

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


# For IPsec tunnel mode

IPSEC_VF_INTF=enp0s1f0d9 ; IPSEC_VF_VSI=18 ; IPSEC_VF_PORT=34
ACC_PR3_INTF=enp0s1f0d6 ; ACC_PR3_VSI=15 ; ACC_PR3_PORT=31

p4rt-ctl add-entry br0 linux_networking_control.tx_source_port        "vmeta.common.vsi=${IPSEC_VF_VSI}/2047,priority=1,action=linux_networking_control.set_source_port(${IPSEC_VF_PORT})"
p4rt-ctl add-entry br0 linux_networking_control.tx_acc_vsi            "vmeta.common.vsi=${ACC_PR3_VSI},zero_padding=0,action=linux_networking_control.l2_fwd_and_bypass_bridge(${IPSEC_VF_PORT})"
p4rt-ctl add-entry br0 linux_networking_control.vsi_to_vsi_loopback   "vmeta.common.vsi=${ACC_PR3_VSI},target_vsi=${IPSEC_VF_VSI},action=linux_networking_control.fwd_to_vsi(${IPSEC_VF_PORT})"
p4rt-ctl add-entry br0 linux_networking_control.vsi_to_vsi_loopback   "vmeta.common.vsi=${IPSEC_VF_VSI},target_vsi=${ACC_PR3_VSI},action=linux_networking_control.fwd_to_vsi(${ACC_PR3_PORT})"
p4rt-ctl add-entry br0 linux_networking_control.source_port_to_pr_map "user_meta.cmeta.source_port=${IPSEC_VF_PORT},zero_padding=0,action=linux_networking_control.fwd_to_vsi(${ACC_PR3_PORT})"


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
ovs-vsctl add-port br-intrnl enp0s1f0d6
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
ip route change 10.1.1.0/24 via 1.1.1.2 dev br-tunl


# set ip for traffic source
nmcli device set $HOST_VF_INTF managed no
ip addr add dev $HOST_VF_INTF 192.168.1.101/24

# For IPsec tunnel mode
nmcli device set $IPSEC_VF_INTF managed no
ip addr add dev $IPSEC_VF_INTF 11.0.0.1/24

# set lower MTU size for IPsec tunnel mode
ip link set dev $IPSEC_VF_INTF mtu 1400


# Cleanup LP
# ==========

ip addr del 10.1.1.2/24 dev TEP10
ip addr del 192.168.1.102/24 dev vxlan10
ip addr del 1.1.1.2/24 dev ens801f0
ip link del vxlan10
ip link del TEP10
ip link del IPSECAPP


### strongSwan config ###
# ===================== #

# On host -> clone and compile https://github.com/ipdk-io/ipsec-recipe
# On LP -> clone and compile standard strongSwan 5.9.3

# 1. Use same ipsec.secrets file contents on both host and LP side
    [root@P8 etc]# cat ipsec.secrets
    # ipsec.secrets - strongSwan IPsec secrets file
    : PSK "example"
    [root@P8 etc]#


# 2. ipsec.conf file examples

# 2a. Host side
    [root@P7 etc]# cat ipsec.conf
    # ipsec.conf - strongSwan IPsec configuration file

    config setup
            charondebug="ike 4, knl 4, cfg 2,enc 4,dmn 2, mgr 2"    #useful debugs


    conn sts-base
        fragmentation=yes
        keyingtries=%forever
        ike=aes256-sha1-modp1024,3des-sha1-modp1024!
        esp=aes256gcm128
        leftauth=psk
        rightauth=psk
        keyexchange=ikev2
        left=192.168.1.101
        right=192.168.1.102
        leftid=192.168.1.101
        rightid=192.168.1.102
        leftsubnet=11.0.0.1
        rightsubnet=11.0.0.2
    #    replay_window=32
    #    lifetime=1
    #    margintime=30m
    #    rekey=yes
        lifebytes=100000000000
        marginbytes=6000000000
        rekey=no
        type=tunnel
        leftprotoport=tcp
        rightprotoport=tcp
        auto=start
    [root@P7 etc]#

# 2b. client side
    [root@P8 etc]# cat ipsec.conf
    # ipsec.conf - strongSwan IPsec configuration file
    # basic configuration - pre-shared key(psk) and ikev2

    config setup
            charondebug="ike 4, knl 4, cfg 2,enc 4,dmn 2, mgr 2"    #useful debugs


    conn sts-base
        fragmentation=yes
        keyingtries=%forever
        ike=aes256-sha1-modp1024,3des-sha1-modp1024!
        esp=aes256gcm128
        leftauth=psk
        rightauth=psk
        keyexchange=ikev2
        left=192.168.1.102
        right=192.168.1.101
        leftid=192.168.1.102
        rightid=192.168.1.101
        leftsubnet=11.0.0.2
        rightsubnet=11.0.0.1
    #    replay_window=32
    #    lifetime=1
    #    margintime=30m
    #    rekey=yes
        lifebytes=100000000000
        marginbytes=6000000000
        rekey=no
        type=tunnel
        leftprotoport=tcp
        rightprotoport=tcp
        auto=add

    [root@P8 etc]#

# 3. Set no_proxy on host to avoid traffic interruption

export no_proxy=intel.com,.intel.com,localhost,127.0.0.1,10.166.0.0/20,10.96.0.0/12,192.168.0.1/24,10.10.0.2/24
export NO_PROXY=intel.com,.intel.com,localhost,127.0.0.1,10.166.0.0/20,10.96.0.0/12,192.168.0.1/24,10.10.0.2/24
unset http_proxy
unset https_proxy
unset ftp_proxy IPROXY FTP_PROXY HTTP_PROXY HTTPS_PROXY SOCKS_PROXY socks_proxy rsync_proxy


# 4. Start strongSwan - first on LP side, then on host

# On LP
ipsec start

# On host
./ipsec start

# check that SAs establish using 'ipsec statusall' command

################ OLD ###########################################
# IPsec (manual config)
#======================

#### IPsec workaround for tx misc errors

# check that this is 0x00000
devmem 0x2024D02000

# Workaround steps

# Following should show ice@4830000
ls -l /proc/device-tree/reserved-memory/ | awk '/ice/{print $NF}'

# Init and allocate memory
devmem 0x2024D02000 32 0x4850000
devmem 0x2024D02400 32 0x80000000

devmem 0x2024E02000 32 0x4830000
devmem 0x2024E02400 32 0x80000000



###########################333


# Use case 1: Basic untagged traffic
# ==================================
ovs-vsctl add-br br-intrnl
ovs-vsctl add-port br-intrnl enp0s1f0d4
ovs-vsctl add-port br-intrnl enp0s1f0d5
ovs-vsctl add-port br-intrnl enp0s1f0d6
ifconfig br-intrnl up
ovs-vsctl show

# On LP
#======
CVL_INTF=ens801f0

ip addr add dev ${CVL_INTF} 192.168.1.102/24

ip link add dev IPSECAPP type dummy
ifconfig IPSECAPP 11.0.0.2/24 up
sleep 1
ip addr show IPSECAPP

ip route change 11.0.0.0/24 dev ${CVL_INTF}


###########################
## Checkpoint. Test #######
## ping host <--> LP
###########################

## Use case 2: VXLAN traffic
# ==========================

# Cleanup previous bridge
# ====================

ifconfig br-intrnl down
ovs-vsctl del-port br-intrnl enp0s1f0d6
ovs-vsctl del-port br-intrnl enp0s1f0d5
ovs-vsctl del-port br-intrnl enp0s1f0d4
ovs-vsctl del-br br-intrnl
ovs-vsctl show

# On LP
# ====
ip addr del dev ens801f0 192.168.1.102/24


