/* p4c-pna-xxp version: 3.0.70.128 */ 

name "Sample P4 Program pkg";
version 1.0.73.35;
segment IDPF_CXP {
    version 1.0.73.35;
    name "Sample P4 Program pkg";
}


segment IDPF_FXP {
    label REG 0 PMD_COMMON;
    label REG 2 PMD_HOST_INFO_TX_BASE;
    label REG 3 PMD_HOST_INFO_RX;
    label REG 4 PMD_GENERIC_32;
    label REG 5 PMD_FXP_INTERNAL;
    label REG 6 PMD_MISC_INTERNAL;
    label REG 7 PMD_HOST_INFO_TX_EXTENDED;
    label REG 8 PMD_PARSE_PTRS_SHORT;
    label REG 10 PMD_RDMARX;
    label REG 12 PMD_PARSE_PTRS;
    label REG 13 PMD_CONFIG;
    label REG 16 PMD_DROP_INFO;

    label PROTOCOL_ID 1 MAC_IN0;
    label PROTOCOL_ID 2 MAC_IN1;
    label PROTOCOL_ID 3 MAC_IN2;
    label PROTOCOL_ID 32 IPV4_IN0;
    label PROTOCOL_ID 33 IPV4_IN1;
    label PROTOCOL_ID 34 IPV4_IN2;
    label PROTOCOL_ID 40 IPV6_IN0;
    label PROTOCOL_ID 41 IPV6_IN1;
    label PROTOCOL_ID 42 IPV6_IN2;
    label PROTOCOL_ID 52 UDP_IN0;
    label PROTOCOL_ID 53 UDP_IN1;
    label PROTOCOL_ID 54 UDP_IN2;
    label PROTOCOL_ID 49 TCP;

    block EVMIN {
        set %AUTO_ADD_RX_TYPE0 %PMD_FXP_INTERNAL;
        set %AUTO_ADD_RX_TYPE1 %PMD_MISC_INTERNAL;
        set %AUTO_ADD_RX_TYPE2 %PMD_PARSE_PTRS;
        set %AUTO_ADD_RX_TYPE3 %PMD_GENERIC_32;

        set %MD_SEL_RX_TYPE0 %PMD_COMMON;
        set %MD_SEL_RX_TYPE1 %PMD_FXP_INTERNAL;
        set %MD_SEL_RX_TYPE2 %PMD_HOST_INFO_RX;
        set %MD_SEL_RX_TYPE3 %PMD_MISC_INTERNAL;
        set %MD_SEL_RX_TYPE4 %PMD_GENERIC_32;

        set %AUTO_ADD_TX_TYPE0 %PMD_FXP_INTERNAL;
        set %AUTO_ADD_TX_TYPE1 %PMD_DROP_INFO;
        set %AUTO_ADD_TX_TYPE2 %PMD_PARSE_PTRS;
        set %AUTO_ADD_TX_TYPE3 %PMD_MISC_INTERNAL;
        set %AUTO_ADD_TX_TYPE4 %PMD_GENERIC_32;

        set %MD_SEL_TX_TYPE0 %PMD_COMMON;
        set %MD_SEL_TX_TYPE1 %PMD_FXP_INTERNAL;
        set %MD_SEL_TX_TYPE2 %PMD_HOST_INFO_TX_BASE;
        set %MD_SEL_TX_TYPE3 %PMD_HOST_INFO_TX_EXTENDED;
        set %MD_SEL_TX_TYPE4 %PMD_MISC_INTERNAL;
        set %MD_SEL_TX_TYPE5 %PMD_GENERIC_32;

        set %AUTO_ADD_CFG_TYPE0 %PMD_FXP_INTERNAL;

        set %MD_SEL_CFG_TYPE0 %PMD_COMMON;
        set %MD_SEL_CFG_TYPE1 %PMD_CONFIG;
        set %MD_SEL_CFG_TYPE2 %PMD_FXP_INTERNAL;
    }

    block EVMOUT {
        set %AUTO_DEL_LAN_RX_TYPE0 %PMD_FXP_INTERNAL;
        set %AUTO_DEL_LAN_RX_TYPE1 %PMD_RDMARX;
        set %AUTO_DEL_LAN_RX_TYPE2 %PMD_GENERIC_32;

        set %AUTO_DEL_LANP2P_RX_TYPE0 %PMD_FXP_INTERNAL;
        set %AUTO_DEL_LANP2P_RX_TYPE1 %PMD_RDMARX;

        set %AUTO_DEL_RDMA_RX_TYPE0 %PMD_FXP_INTERNAL;
        set %AUTO_DEL_RDMA_RX_TYPE1 %PMD_MISC_INTERNAL;
        set %AUTO_DEL_RDMA_RX_TYPE2 %PMD_GENERIC_32;

        set %AUTO_DEL_RECIRC_RX_TYPE0 %PMD_PARSE_PTRS;
        set %AUTO_DEL_RECIRC_RX_TYPE1 %PMD_PARSE_PTRS_SHORT;

        set %AUTO_DEL_RECIRC_TX_TYPE0 %PMD_PARSE_PTRS;
        set %AUTO_DEL_RECIRC_TX_TYPE1 %PMD_PARSE_PTRS_SHORT;

        set %AUTO_DEL_TX_TYPE0 %PMD_FXP_INTERNAL;
        set %AUTO_DEL_TX_TYPE1 %PMD_HOST_INFO_TX_EXTENDED;

        set %AUTO_DEL_CFG_TYPE0 %PMD_FXP_INTERNAL;
    }

    block SEM {
        set %PAGE_SIZE 2MB;
    }

    block LEM {
        set %PAGE_SIZE 2MB;
        set %AGING_PAGE_SIZE 2MB;

        set %FLOW_ID_MAX 12; //2^9 = 512
        set %FLOW_ID_BUFF_THR_HIGH 'hE00;
        set %FLOW_ID_BUFF_THR_LOW 'h200;
        set %AGE_TICK 7500;

       //Current model requires this protocol to be set to 0 if ATR is not enabled

        set %TCP_PROTOCOL_ID 0;
        set %EVICT_FLAGS 0;
        set %PINNED 0;
        set %INSERT_MODE FIXED_FETCH;
    }
}


segment IDPF_FXP {

    domain 0 {
        name "Sample P4 Program pkg";
    }
    domain 0 {
        version 1.0.73.35;
        external_version 0 1.0.73.35;
    }

    label DOMAIN 0 GLOBAL;    label PROTOCOL_ID 255 PROTO_ID_INVALID;
    label PROTOCOL_ID 1 MAC_IN0;
    label PROTOCOL_ID 2 MAC_IN1;
    label PROTOCOL_ID 3 MAC_IN2;
    label PROTOCOL_ID 4 reserved4;
    label PROTOCOL_ID 9 ETYPE_IN0;
    label PROTOCOL_ID 10 ETYPE_IN1;
    label PROTOCOL_ID 11 ETYPE_IN2;
    label PROTOCOL_ID 15 PAY;
    label PROTOCOL_ID 16 VLAN_EXT_IN0;
    label PROTOCOL_ID 17 VLAN_EXT_IN1;
    label PROTOCOL_ID 18 VLAN_EXT_IN2;
    label PROTOCOL_ID 19 VLAN_INT_IN0;
    label PROTOCOL_ID 20 VLAN_INT_IN1;
    label PROTOCOL_ID 21 VLAN_INT_IN2;
    label PROTOCOL_ID 32 IPV4_IN0;
    label PROTOCOL_ID 33 IPV4_IN1;
    label PROTOCOL_ID 34 IPV4_IN2;
    label PROTOCOL_ID 36 IP_NEXT_HDR_LAST_IN0;
    label PROTOCOL_ID 37 IP_NEXT_HDR_LAST_IN1;
    label PROTOCOL_ID 38 IP_NEXT_HDR_LAST_IN2;
    label PROTOCOL_ID 40 IPV6_IN0;
    label PROTOCOL_ID 41 IPV6_IN1;
    label PROTOCOL_ID 42 IPV6_IN2;
    label PROTOCOL_ID 49 TCP;
    label PROTOCOL_ID 52 UDP_IN0;
    label PROTOCOL_ID 53 UDP_IN1;
    label PROTOCOL_ID 54 UDP_IN2;
    label PROTOCOL_ID 118 ARP;
    label PROTOCOL_ID 124 L4_IN0;
    label PROTOCOL_ID 125 VXLAN_IN1;
    label PROTOCOL_ID 126 VXLAN_IN2;
    label PROTOCOL_ID 127 L4_IN1;
    label PROTOCOL_ID 128 GENEVE_IN0;
    label PROTOCOL_ID 131 GENTUN_IN0;
    label PROTOCOL_ID 200 VLAN_ETYPE_START_IN0;
    label PROTOCOL_ID 201 VLAN_ETYPE_START_IN1;
    label PROTOCOL_ID 202 VLAN_ETYPE_START_IN2;

    label FLAG 14 PACKET_FLAG_14;
    label FLAG 15 PACKET_FLAG_15;
    label FLAG 16 PACKET_FLAG_16;
    label FLAG 17 PACKET_FLAG_17;
    label FLAG 18 PACKET_FLAG_18;
    label FLAG 19 PACKET_FLAG_19;
    label FLAG 20 PACKET_FLAG_20;
    label FLAG 21 PACKET_FLAG_21;
    label FLAG 22 PACKET_FLAG_22;
    label FLAG 23 PACKET_FLAG_23;
    label FLAG 24 PACKET_FLAG_24;
    label FLAG 25 PACKET_FLAG_25;
    label FLAG 26 PACKET_FLAG_26;
    label FLAG 27 PACKET_FLAG_27;
    label REG STATE[59:59] MARKER0;
    label REG STATE[60:60] MARKER1;
    label REG STATE[61:61] MARKER2;
    label REG STATE[62:62] MARKER3;
    label REG STATE[63:63] MARKER4;
    label REG STATE[64:64] MARKER5;
    label REG STATE[65:65] MARKER6;
    label REG STATE[66:66] MARKER7;

    label PTYPE 1 PTYPE_MAC_PAY;
    label PTYPE 11 PTYPE_MAC_ARP;
    label PTYPE 23 PTYPE_MAC_IPV4_PAY;
    label PTYPE 24 PTYPE_MAC_IPV4_UDP;
    label PTYPE 26 PTYPE_MAC_IPV4_TCP;
    label PTYPE 33 PTYPE_MAC_IPV6_PAY;
    label PTYPE 34 PTYPE_MAC_IPV6_UDP;
    label PTYPE 35 PTYPE_MAC_IPV6_TCP;
    label PTYPE 58 PTYPE_MAC_IPV4_TUN_MAC_PAY;
    label PTYPE 59 PTYPE_MAC_IPV6_TUN_MAC_PAY;
    label PTYPE 60 PTYPE_MAC_IPV4_TUN_MAC_IPV4_PAY;
    label PTYPE 61 PTYPE_MAC_IPV4_TUN_MAC_IPV4_UDP;
    label PTYPE 63 PTYPE_MAC_IPV4_TUN_MAC_IPV4_TCP;
    label PTYPE 70 PTYPE_MAC_IPV4_TUN_MAC_IPV6_PAY;
    label PTYPE 71 PTYPE_MAC_IPV4_TUN_MAC_IPV6_UDP;
    label PTYPE 72 PTYPE_MAC_IPV4_TUN_MAC_IPV6_TCP;
    label PTYPE 80 PTYPE_MAC_IPV6_TUN_MAC_IPV4_PAY;
    label PTYPE 81 PTYPE_MAC_IPV6_TUN_MAC_IPV4_UDP;
    label PTYPE 82 PTYPE_MAC_IPV6_TUN_MAC_IPV4_TCP;
    label PTYPE 90 PTYPE_MAC_IPV6_TUN_MAC_IPV6_PAY;
    label PTYPE 91 PTYPE_MAC_IPV6_TUN_MAC_IPV6_UDP;
    label PTYPE 92 PTYPE_MAC_IPV6_TUN_MAC_IPV6_TCP;
    label PTYPE 100 PTYPE_MAC_IPV4_GENEVE_IPV4_PAY;
    label PTYPE 101 PTYPE_MAC_IPV4_GENEVE_IPV4_UDP;
    label PTYPE 102 PTYPE_MAC_IPV4_GENEVE_IPV4_TCP;
    label PTYPE 103 PTYPE_MAC_IPV4_GENEVE_IPV4_ICMP;
    label PTYPE 110 PTYPE_MAC_IPV4_GENEVE_MAC_IPV4_PAY;
    label PTYPE 111 PTYPE_MAC_IPV4_GENEVE_MAC_IPV4_UDP;
    label PTYPE 112 PTYPE_MAC_IPV4_GENEVE_MAC_IPV4_TCP;
    label PTYPE 113 PTYPE_MAC_IPV4_GENEVE_MAC_IPV4_ICMP;
    label PTYPE 114 PTYPE_MAC_IPV4_GENEVE_MAC_IPV6_PAY;
    label PTYPE 115 PTYPE_MAC_IPV4_GENEVE_MAC_IPV6_UDP;
    label PTYPE 116 PTYPE_MAC_IPV4_GENEVE_MAC_IPV6_TCP;
    label PTYPE 117 PTYPE_MAC_IPV4_GENEVE_MAC_IPV6_ICMP6;
    label PTYPE 118 PTYPE_MAC_IPV4_GENEVE_MAC_PAY;
    label PTYPE 119 PTYPE_MAC_IPV4_GENEVE_MAC_ARP;
    label PTYPE 120 PTYPE_MAC_IPV6_GENEVE_IPV4_PAY;
    label PTYPE 121 PTYPE_MAC_IPV6_GENEVE_IPV4_UDP;
    label PTYPE 122 PTYPE_MAC_IPV6_GENEVE_IPV4_TCP;
    label PTYPE 123 PTYPE_MAC_IPV6_GENEVE_IPV4_ICMP;
    label PTYPE 124 PTYPE_MAC_IPV6_GENEVE_MAC_IPV4_PAY;
    label PTYPE 125 PTYPE_MAC_IPV6_GENEVE_MAC_IPV4_UDP;
    label PTYPE 126 PTYPE_MAC_IPV6_GENEVE_MAC_IPV4_TCP;
    label PTYPE 127 PTYPE_MAC_IPV6_GENEVE_MAC_IPV4_ICMP;
    label PTYPE 128 PTYPE_MAC_IPV6_GENEVE_MAC_IPV6_PAY;
    label PTYPE 129 PTYPE_MAC_IPV6_GENEVE_MAC_IPV6_UDP;
    label PTYPE 130 PTYPE_MAC_IPV6_GENEVE_MAC_IPV6_TCP;
    label PTYPE 131 PTYPE_MAC_IPV6_GENEVE_MAC_IPV6_ICMP6;
    label PTYPE 132 PTYPE_MAC_IPV6_GENEVE_MAC_PAY;
    label PTYPE 140 PTYPE_MAC_IPV4_IPV4_PAY;
    label PTYPE 141 PTYPE_MAC_IPV4_IPV4_UDP;
    label PTYPE 142 PTYPE_MAC_IPV4_IPV4_TCP;
    label PTYPE 150 PTYPE_MAC_IPV4_TUN_MAC_IPV4_IPV4_PAY;
    label PTYPE 151 PTYPE_MAC_IPV4_TUN_MAC_IPV4_IPV4_UDP;
    label PTYPE 152 PTYPE_MAC_IPV4_TUN_MAC_IPV4_IPV4_TCP;
    label PTYPE 153 PTYPE_MAC_IPV4_GENEVE_MAC_IPV4_IPV4_PAY;
    label PTYPE 154 PTYPE_MAC_IPV4_GENEVE_MAC_IPV4_IPV4_UDP;
    label PTYPE 155 PTYPE_MAC_IPV4_GENEVE_MAC_IPV4_IPV4_TCP;
    label PTYPE 287 PTYPE_MAC_IPV4_TUN_MAC_ARP;
    label PTYPE 288 PTYPE_MAC_IPV6_TUN_MAC_ARP;
    label PTYPE 1022 PTYPE_REJECT;

    label REG STATE[7:0]   S0;
    label REG STATE[15:8]  S1;
    label REG STATE[23:16] S2;
    label REG STATE[31:24] S3;
    label REG STATE[39:32] S4;
    label REG STATE[47:40] S5;
    label REG STATE[55:48] S6;
    label REG STATE[63:56] S7;
    label REG STATE[58:56] NODEID;
    label REG STATE[77:59] MARKERS;
    label REG STATE[79:78] WAY_SEL;
    label REG 31[7:0] NULL;

    label REG 31[7:0] UNUSED_INIT_KEY;

block PARSER {


    direction RX {
		set %INIT_KEY0  %UNUSED_INIT_KEY;
		set %INIT_KEY1  %UNUSED_INIT_KEY;
		set %INIT_KEY2  %UNUSED_INIT_KEY;
		set %INIT_KEY3  %UNUSED_INIT_KEY;
		set %INIT_KEY4  %UNUSED_INIT_KEY;
		set %INIT_KEY5  %UNUSED_INIT_KEY;
		set %INIT_KEY6  %UNUSED_INIT_KEY;
		set %INIT_KEY7  %UNUSED_INIT_KEY;
		set %INIT_KEY8  %UNUSED_INIT_KEY;
		set %INIT_KEY9  %UNUSED_INIT_KEY;
		set %INIT_KEY10  %UNUSED_INIT_KEY;
		set %INIT_KEY11  %UNUSED_INIT_KEY;
    }

    direction TX {
		set %INIT_KEY0  %UNUSED_INIT_KEY;
		set %INIT_KEY1  %UNUSED_INIT_KEY;
		set %INIT_KEY2  %UNUSED_INIT_KEY;
		set %INIT_KEY3  %UNUSED_INIT_KEY;
		set %INIT_KEY4  %UNUSED_INIT_KEY;
		set %INIT_KEY5  %UNUSED_INIT_KEY;
		set %INIT_KEY6  %UNUSED_INIT_KEY;
		set %INIT_KEY7  %UNUSED_INIT_KEY;
		set %INIT_KEY8  %UNUSED_INIT_KEY;
		set %INIT_KEY9  %UNUSED_INIT_KEY;
		set %INIT_KEY10  %UNUSED_INIT_KEY;
		set %INIT_KEY11  %UNUSED_INIT_KEY;
    }

    set %DEFAULT_PTYPE 255;
    set %CSUM_CONFIG_IPV4_0 32;
    set %CSUM_CONFIG_IPV4_1 33;
    set %CSUM_CONFIG_IPV4_2 34;
    set %CSUM_CONFIG_IPV6_0 40;
    set %CSUM_CONFIG_IPV6_1 41;
    set %CSUM_CONFIG_IPV6_2 42;
    set %CSUM_CONFIG_UDP_0 52;
    set %CSUM_CONFIG_UDP_1 53;
    set %CSUM_CONFIG_UDP_2 54;
    set %CSUM_CONFIG_TCP_0 49;
    set %PROTO_STACK_SIZE 26;

    tcam INIT_ID(%INIT_KEY0){
	'h?? : 0;
    }

	table METADATA_INIT(%INIT_ID){

	0 : FLAGS('b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000),
		STATE0(0),
		STATE1(0),
		STATE2(0),
		STATE3(0),
		STATE4(0),
		STATE5(0),
		STATE6(0),
		STATE7(0),
		STATE8(0),
		STATE9(0),
		HO(0),
		W0(0),
		W1(0),
		W2(0);
	}


	tcam PTYPE(%ERROR, %MARKER7, %MARKER6, %MARKER5, %MARKER4, %MARKER3, %MARKER2, %MARKER1, %MARKER0, %NODEID, %STATE[79:67]) {
		'b0, 'b0, 'b1, 'b0, 'b0, 'b0, 'b0, 'b1, 'b1, 1, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV4_TUN_MAC_ARP),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b0, 'b1, 'b0, 'b1, 'b0, 'b0, 'b0, 'b1, 1, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV6_TUN_MAC_ARP),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b1, 'b0, 'b0, 'b0, 'b0, 'b0, 'b1, 'b1, 1, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV4_GENEVE_MAC_ARP),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b1, 'b0, 'b0, 'b1, 'b0, 'b0, 'b0, 'b1, 1, 'b?_?000_0000_0000 : PTYPE(29),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b0, 'b0, 'b0, 'b0, 'b0, 'b0, 'b0, 'b0, 1, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_ARP),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b0, 'b0, 'b0, 'b0, 'b0, 'b0, 'b1, 'b0, 4, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV4_PAY),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b0, 'b0, 'b0, 'b1, 'b0, 'b0, 'b0, 'b0, 4, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV6_PAY),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b1, 'b0, 'b0, 'b0, 'b0, 'b0, 'b1, 'b0, 4, 'b?_?000_0000_0000 : PTYPE(17),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b1, 'b0, 'b0, 'b1, 'b0, 'b0, 'b0, 'b0, 4, 'b?_?000_0000_0000 : PTYPE(18),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b0, 'b1, 'b0, 'b0, 'b0, 'b0, 'b1, 'b1, 4, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV4_TUN_MAC_PAY),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b0, 'b1, 'b0, 'b1, 'b0, 'b0, 'b0, 'b1, 4, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV6_TUN_MAC_PAY),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b1, 'b0, 'b0, 'b0, 'b0, 'b0, 'b1, 'b1, 4, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV4_GENEVE_MAC_PAY),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b1, 'b0, 'b0, 'b1, 'b0, 'b0, 'b0, 'b1, 4, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV6_GENEVE_MAC_PAY),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b0, 'b0, 'b0, 'b0, 'b0, 'b1, 'b1, 'b0, 4, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV4_IPV4_PAY),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b1, 'b0, 'b0, 'b0, 'b0, 'b1, 'b1, 'b0, 4, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV4_GENEVE_IPV4_PAY),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b1, 'b0, 'b0, 'b1, 'b0, 'b1, 'b0, 'b0, 4, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV6_GENEVE_IPV4_PAY),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b0, 'b1, 'b0, 'b0, 'b0, 'b1, 'b1, 'b1, 4, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV4_TUN_MAC_IPV4_PAY),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b0, 'b1, 'b0, 'b1, 'b0, 'b1, 'b0, 'b1, 4, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV6_TUN_MAC_IPV4_PAY),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b1, 'b0, 'b0, 'b0, 'b0, 'b1, 'b1, 'b1, 4, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV4_GENEVE_MAC_IPV4_PAY),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b1, 'b0, 'b0, 'b1, 'b0, 'b1, 'b0, 'b1, 4, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV6_GENEVE_MAC_IPV4_PAY),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b0, 'b0, 'b0, 'b0, 'b1, 'b1, 'b1, 'b0, 4, 'b?_?000_0000_0000 : PTYPE(19),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b1, 'b0, 'b0, 'b0, 'b1, 'b1, 'b1, 'b0, 4, 'b?_?000_0000_0000 : PTYPE(20),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b1, 'b0, 'b0, 'b1, 'b1, 'b1, 'b0, 'b0, 4, 'b?_?000_0000_0000 : PTYPE(21),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b0, 'b1, 'b0, 'b0, 'b1, 'b1, 'b1, 'b1, 4, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV4_TUN_MAC_IPV4_IPV4_PAY),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b0, 'b1, 'b0, 'b1, 'b1, 'b1, 'b0, 'b1, 4, 'b?_?000_0000_0000 : PTYPE(22),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b1, 'b0, 'b0, 'b0, 'b1, 'b1, 'b1, 'b1, 4, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV4_GENEVE_MAC_IPV4_IPV4_PAY),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b1, 'b0, 'b0, 'b1, 'b1, 'b1, 'b0, 'b1, 4, 'b?_?000_0000_0000 : PTYPE(25),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b1, 'b0, 'b1, 'b0, 'b0, 'b0, 'b1, 'b0, 4, 'b?_?000_0000_0000 : PTYPE(27),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b1, 'b0, 'b1, 'b1, 'b0, 'b0, 'b0, 'b0, 4, 'b?_?000_0000_0000 : PTYPE(28),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b0, 'b1, 'b1, 'b0, 'b0, 'b0, 'b1, 'b1, 4, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV4_TUN_MAC_IPV6_PAY),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b0, 'b1, 'b1, 'b1, 'b0, 'b0, 'b0, 'b1, 4, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV6_TUN_MAC_IPV6_PAY),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b1, 'b0, 'b1, 'b0, 'b0, 'b0, 'b1, 'b1, 4, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV4_GENEVE_MAC_IPV6_PAY),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b1, 'b0, 'b1, 'b1, 'b0, 'b0, 'b0, 'b1, 4, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV6_GENEVE_MAC_IPV6_PAY),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b0, 'b0, 'b0, 'b0, 'b0, 'b0, 'b0, 'b0, 4, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_PAY),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b1, 'b0, 'b1, 'b0, 'b0, 'b0, 'b1, 'b1, 6, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV4_GENEVE_MAC_IPV6_ICMP6),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b1, 'b0, 'b1, 'b1, 'b0, 'b0, 'b0, 'b1, 6, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV6_GENEVE_MAC_IPV6_ICMP6),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b0, 'b0, 'b0, 'b0, 'b0, 'b0, 'b1, 'b0, 2, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV4_TCP),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b0, 'b0, 'b0, 'b1, 'b0, 'b0, 'b0, 'b0, 2, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV6_TCP),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b0, 'b0, 'b0, 'b0, 'b0, 'b1, 'b1, 'b0, 2, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV4_IPV4_TCP),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b1, 'b0, 'b0, 'b0, 'b0, 'b1, 'b1, 'b0, 2, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV4_GENEVE_IPV4_TCP),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b1, 'b0, 'b0, 'b1, 'b0, 'b1, 'b0, 'b0, 2, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV6_GENEVE_IPV4_TCP),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b0, 'b1, 'b0, 'b0, 'b0, 'b1, 'b1, 'b1, 2, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV4_TUN_MAC_IPV4_TCP),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b0, 'b1, 'b0, 'b1, 'b0, 'b1, 'b0, 'b1, 2, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV6_TUN_MAC_IPV4_TCP),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b1, 'b0, 'b0, 'b0, 'b0, 'b1, 'b1, 'b1, 2, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV4_GENEVE_MAC_IPV4_TCP),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b1, 'b0, 'b0, 'b1, 'b0, 'b1, 'b0, 'b1, 2, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV6_GENEVE_MAC_IPV4_TCP),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b0, 'b0, 'b0, 'b0, 'b1, 'b1, 'b1, 'b0, 2, 'b?_?000_0000_0000 : PTYPE(9),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b1, 'b0, 'b0, 'b0, 'b1, 'b1, 'b1, 'b0, 2, 'b?_?000_0000_0000 : PTYPE(10),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b1, 'b0, 'b0, 'b1, 'b1, 'b1, 'b0, 'b0, 2, 'b?_?000_0000_0000 : PTYPE(12),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b0, 'b1, 'b0, 'b0, 'b1, 'b1, 'b1, 'b1, 2, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV4_TUN_MAC_IPV4_IPV4_TCP),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b0, 'b1, 'b0, 'b1, 'b1, 'b1, 'b0, 'b1, 2, 'b?_?000_0000_0000 : PTYPE(13),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b1, 'b0, 'b0, 'b0, 'b1, 'b1, 'b1, 'b1, 2, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV4_GENEVE_MAC_IPV4_IPV4_TCP),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b1, 'b0, 'b0, 'b1, 'b1, 'b1, 'b0, 'b1, 2, 'b?_?000_0000_0000 : PTYPE(14),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b1, 'b0, 'b1, 'b0, 'b0, 'b0, 'b1, 'b0, 2, 'b?_?000_0000_0000 : PTYPE(15),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b1, 'b0, 'b1, 'b1, 'b0, 'b0, 'b0, 'b0, 2, 'b?_?000_0000_0000 : PTYPE(16),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b0, 'b1, 'b1, 'b0, 'b0, 'b0, 'b1, 'b1, 2, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV4_TUN_MAC_IPV6_TCP),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b0, 'b1, 'b1, 'b1, 'b0, 'b0, 'b0, 'b1, 2, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV6_TUN_MAC_IPV6_TCP),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b1, 'b0, 'b1, 'b0, 'b0, 'b0, 'b1, 'b1, 2, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV4_GENEVE_MAC_IPV6_TCP),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b1, 'b0, 'b1, 'b1, 'b0, 'b0, 'b0, 'b1, 2, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV6_GENEVE_MAC_IPV6_TCP),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b0, 'b0, 'b0, 'b0, 'b0, 'b0, 'b1, 'b0, 3, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV4_UDP),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b0, 'b0, 'b0, 'b1, 'b0, 'b0, 'b0, 'b0, 3, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV6_UDP),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b0, 'b0, 'b0, 'b0, 'b1, 'b1, 'b1, 'b0, 3, 'b?_?000_0000_0000 : PTYPE(2),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b1, 'b0, 'b0, 'b0, 'b1, 'b1, 'b1, 'b0, 3, 'b?_?000_0000_0000 : PTYPE(3),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b1, 'b0, 'b0, 'b1, 'b1, 'b1, 'b0, 'b0, 3, 'b?_?000_0000_0000 : PTYPE(4),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b0, 'b1, 'b0, 'b0, 'b1, 'b1, 'b1, 'b1, 3, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV4_TUN_MAC_IPV4_IPV4_UDP),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b0, 'b1, 'b0, 'b1, 'b1, 'b1, 'b0, 'b1, 3, 'b?_?000_0000_0000 : PTYPE(5),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b1, 'b0, 'b0, 'b0, 'b1, 'b1, 'b1, 'b1, 3, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV4_GENEVE_MAC_IPV4_IPV4_UDP),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b1, 'b0, 'b0, 'b1, 'b1, 'b1, 'b0, 'b1, 3, 'b?_?000_0000_0000 : PTYPE(6),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b0, 'b0, 'b0, 'b0, 'b0, 'b1, 'b1, 'b0, 3, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV4_IPV4_UDP),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b1, 'b0, 'b0, 'b0, 'b0, 'b1, 'b1, 'b0, 3, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV4_GENEVE_IPV4_UDP),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b1, 'b0, 'b0, 'b1, 'b0, 'b1, 'b0, 'b0, 3, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV6_GENEVE_IPV4_UDP),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b0, 'b1, 'b0, 'b0, 'b0, 'b1, 'b1, 'b1, 3, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV4_TUN_MAC_IPV4_UDP),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b0, 'b1, 'b0, 'b1, 'b0, 'b1, 'b0, 'b1, 3, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV6_TUN_MAC_IPV4_UDP),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b1, 'b0, 'b0, 'b0, 'b0, 'b1, 'b1, 'b1, 3, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV4_GENEVE_MAC_IPV4_UDP),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b1, 'b0, 'b0, 'b1, 'b0, 'b1, 'b0, 'b1, 3, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV6_GENEVE_MAC_IPV4_UDP),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b1, 'b0, 'b1, 'b0, 'b0, 'b0, 'b1, 'b0, 3, 'b?_?000_0000_0000 : PTYPE(7),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b1, 'b0, 'b1, 'b1, 'b0, 'b0, 'b0, 'b0, 3, 'b?_?000_0000_0000 : PTYPE(8),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b0, 'b1, 'b1, 'b0, 'b0, 'b0, 'b1, 'b1, 3, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV4_TUN_MAC_IPV6_UDP),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b0, 'b1, 'b1, 'b1, 'b0, 'b0, 'b0, 'b1, 3, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV6_TUN_MAC_IPV6_UDP),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b1, 'b0, 'b1, 'b0, 'b0, 'b0, 'b1, 'b1, 3, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV4_GENEVE_MAC_IPV6_UDP),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b1, 'b0, 'b1, 'b1, 'b0, 'b0, 'b0, 'b1, 3, 'b?_?000_0000_0000 : PTYPE(PTYPE_MAC_IPV6_GENEVE_MAC_IPV6_UDP),
			L3_IN0_CSUM(ENABLE),
			L3_IN1_CSUM(ENABLE),
			L3_IN2_CSUM(ENABLE),
			L4_IN0_ASSOC(0),
			L4_IN1_ASSOC(1),
			L4_IN2_ASSOC(2);
		'b0, 'b0, 'b0, 'b0, 'b0, 'b0, 'b0, 'b0, 'b0, 7, 'b?_?000_0000_0000 : PTYPE(PTYPE_REJECT),
			L3_IN0_CSUM(DISABLE),
			L3_IN1_CSUM(DISABLE),
			L3_IN2_CSUM(DISABLE),
			L4_IN0_ASSOC(DISABLE),
			L4_IN1_ASSOC(DISABLE),
			L4_IN2_ASSOC(DISABLE);
    }

	stage 0 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();
		@0 { 'h????, 'h????, 'h??, 'h??, 'h??, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: start */
				set %W0_OFFSET 0;
				set %W1_OFFSET 2;
				set %WAY_SEL 0;
				set %S6 2;
				set %S5 127;
				alu 0 { NOP; }
				alu 1 { NOP; }
			}

		}

		}
	}
	stage 1 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();
		@0 { 'hFFFF, 'hFFFF, 'h??, 2, 'h7F, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_MAC_Maybe_BC_Depth0 */
				set %W0_OFFSET 4;
				set %S6 2;
				set %S5 126;
				alu 0 { NOP; }
				alu 1 { NOP; }
			}

		}
		@1 { 'b????_????_????_???1, 'h????, 'h??, 2, 'h7F, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_MAC_MC_Depth0 */
				set %PACKET_FLAG_16 1;
				set %S6 2;
				set %S5 124;
				alu 0 { NOP; }
				alu 1 { NOP; }
			}

		}

		}
	}
	stage 2 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();
		@0 { 'hFFFF, 'h????, 'h??, 2, 'h7E, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_MAC_BC_Depth0 */
				set %PACKET_FLAG_15 1;
				set %PROTO_SLOT_NEXT 0, MAC_IN0, MAC_IN1, MAC_IN2, PROTO_ID_INVALID;
				set %PROTO_SLOT_NEXT 12, VLAN_ETYPE_START_IN0, VLAN_ETYPE_START_IN0, VLAN_ETYPE_START_IN0, PROTO_ID_INVALID;
				set %W0_OFFSET 12;
				set %S6 6;
				set %S5 125;
				alu 0 { ADD %HO, 12; }
				alu 1 { NOP; }
			}

		}
		@1 { 'h????, 'h????, 'h??, 2, 'h??, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_MAC_Done_Depth0 */
				set %PROTO_SLOT_NEXT 0, MAC_IN0, MAC_IN1, MAC_IN2, PROTO_ID_INVALID;
				set %PROTO_SLOT_NEXT 12, VLAN_ETYPE_START_IN0, VLAN_ETYPE_START_IN0, VLAN_ETYPE_START_IN0, PROTO_ID_INVALID;
				set %W0_OFFSET 12;
				set %S6 6;
				set %S5 125;
				alu 0 { ADD %HO, 12; }
				alu 1 { NOP; }
			}

		}

		}
	}
	stage 3 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();
		@0 { 'h0081, 'h????, 'h??, 6, 'h7D, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_CTag_Depth0 */
				set %PACKET_FLAG_14 1;
				set %PROTO_SLOT_NEXT 0, VLAN_EXT_IN0, VLAN_EXT_IN1, VLAN_EXT_IN2, PROTO_ID_INVALID;
				set %W0_OFFSET 4;
				set %S6 6;
				set %S5 122;
				alu 0 { ADD %HO, 4; }
				alu 1 { NOP; }
			}

		}
		@1 { 'hA888, 'h????, 'h??, 6, 'h7D, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_STag_Depth0 */
				set %PACKET_FLAG_14 1;
				set %PROTO_SLOT_NEXT 0, VLAN_EXT_IN0, VLAN_EXT_IN1, VLAN_EXT_IN2, PROTO_ID_INVALID;
				set %W0_OFFSET 4;
				set %S6 6;
				set %S5 122;
				alu 0 { ADD %HO, 4; }
				alu 1 { NOP; }
			}

		}

		}
	}
	stage 4 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();
		@0 { 'h0081, 'h????, 'h??, 6, 'h7A, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_CTag_DoubleVLAN_Depth0 */
				set %PROTO_SLOT_NEXT 0, VLAN_INT_IN0, VLAN_INT_IN1, VLAN_INT_IN2, PROTO_ID_INVALID;
				set %S6 6;
				set %S5 120;
				alu 0 { ADD %HO, 4; }
				alu 1 { NOP; }
			}

		}

		}
	}
	stage 5 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();
		@0 { 'h????, 'h????, 'h??, 6, 'h??, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_ETYPE_Depth0 */
				set %PROTO_SLOT_NEXT 0, ETYPE_IN0, ETYPE_IN1, ETYPE_IN2, PROTO_ID_INVALID;
				set %W0_OFFSET 0;
				set %S6 11;
				set %S5 119;
				alu 0 { ADD %HO, 2; }
				alu 1 { NOP; }
			}

		}

		}
	}
	stage 6 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();
		@0 { 'h0008, 'h????, 'h??, 11, 'h77, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_IPv4_Depth0 */
				set %MARKER1 1;
				set %W0_OFFSET 0;
				set %S6 8;
				set %S5 113;
				alu 0 { NOP; }
				alu 1 { NOP; }
			}

		}
		@1 { 'hDD86, 'h????, 'h??, 11, 'h77, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_IPv6_Depth0 */
				set %MARKER4 1;
				set %PROTO_SLOT_NEXT 0, IPV6_IN0, IPV6_IN1, IPV6_IN2, PROTO_ID_INVALID;
				set %W0_OFFSET 6;
				set %S6 11;
				set %S5 111;
				alu 0 { ADD %HO, 40; }
				alu 1 { NOP; }
			}

		}
		@2 { 'h0608, 'h????, 'h??, 11, 'h77, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_ARP */
				set %NODEID 1;
				set %PROTO_SLOT_NEXT 0, ARP, ARP, ARP, PROTO_ID_INVALID;
				set %PROTO_SLOT_NEXT 28, PAY, PAY, PAY, PAY;
				set %FLAG_DONE 1;
				set %S6 10;
				set %S5 118;
				alu 0 { NOP; }
				alu 1 { NOP; }
			}

		}

		}
	}
	stage 7 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();
		@0 { 'b????_????_????_00??, 'h????, 'h??, 8, 'h71, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_Hdr_Too_Short */
				set %PACKET_FLAG_17 1;
				set %S6 11;
				set %S5 117;
				alu 0 { NOP; }
				alu 1 { NOP; }
			}

		}
		@1 { 'h???4, 'h????, 'h??, 8, 'h71, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_Hdr_Too_Short */
				set %PACKET_FLAG_17 1;
				set %S6 11;
				set %S5 117;
				alu 0 { NOP; }
				alu 1 { NOP; }
			}

		}
		@2 { 'h??11, 'h????, 'h??, 11, 'h6F, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_UDP_Depth0 */
				set %PROTO_SLOT_NEXT 0, UDP_IN0, UDP_IN1, UDP_IN2, PROTO_ID_INVALID;
				set %PROTO_SLOT_NEXT 0, L4_IN0, L4_IN1, PROTO_ID_INVALID, PROTO_ID_INVALID;
				set %W0_OFFSET 2;
				set %S6 44;
				set %S5 84;
				alu 0 { ADD %HO, 8; }
				alu 1 { NOP; }
			}

		}
		@3 { 'h??06, 'h????, 'h??, 11, 'h6F, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_TCP */
				set %W0_OFFSET 12;
				set %S6 14;
				set %S5 93;
				alu 0 { NOP; }
				alu 1 { NOP; }
			}

		}
		@4 { 'h??3A, 'h????, 'h??, 11, 'h6F, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_icmpv6 */
				set %NODEID 6;
				set %W0_OFFSET 0;
				set %S6 11;
				set %S5 103;
				alu 0 { ADD %HO, 4; }
				alu 1 { NOP; }
			}

		}
		@5 { 'h????, 'h????, 'h??, 8, 'h??, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_IPv4_Check_Frag_Depth0 */
				set %W0_OFFSET 6;
				set %S6 17;
				set %S5 109;
				alu 0 { NOP; }
				alu 1 { NOP; }
			}

		}

		}
	}
	stage 8 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();
		@0 { 'b0000_0000_??00_0000, 'h????, 'h??, 17, 'h6D, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_IPv4_NextProto_Depth0 */
				set %PROTO_SLOT_NEXT 9, IP_NEXT_HDR_LAST_IN0, IP_NEXT_HDR_LAST_IN1, IP_NEXT_HDR_LAST_IN2, PROTO_ID_INVALID;
				set %PROTO_SLOT_NEXT 0, IPV4_IN0, IPV4_IN1, IPV4_IN2, PROTO_ID_INVALID;
				set %W0_OFFSET 9;
				set %W2_OFFSET 0;
				set %S6 39;
				set %S5 106;
				alu 0 { ADD %HO, (%W2 & 'h0F) << 2 + 0; }
				alu 1 { NOP; }
			}

		}
		@1 { 'b0000_0000_??10_0000, 'h????, 'h??, 17, 'h6D, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_IPv4_Frag_Head_Depth0 */
				set %PACKET_FLAG_18 1;
				set %S6 17;
				set %S5 100;
				alu 0 { NOP; }
				alu 1 { NOP; }
			}

		}

		}
	}
	stage 9 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();
		@0 { 'h??11, 'h????, 'h??, 39, 'h6A, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_UDP_Depth0_delay */
				set %S6 18;
				set %S5 69;
				alu 0 { NOP; }
				alu 1 { NOP; }
			}

		}
		@1 { 'h??06, 'h????, 'h??, 39, 'h6A, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_TCP */
				set %W0_OFFSET 12;
				set %S6 14;
				set %S5 93;
				alu 0 { NOP; }
				alu 1 { NOP; }
			}

		}
		@2 { 'h??04, 'h????, 'h??, 39, 'h6A, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_IPV4_In_IPV4_Depth1 */
				set %PACKET_FLAG_20 1;
				set %PACKET_FLAG_21 0;
				set %S6 19;
				set %S5 115;
				alu 0 { NOP; }
				alu 1 { NOP; }
			}

		}
		@3 { 'h????, 'h????, 'h??, 17, 'h??, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_IPv4_Frag_Depth0 */
				set %PROTO_SLOT_NEXT 9, IP_NEXT_HDR_LAST_IN0, IP_NEXT_HDR_LAST_IN1, IP_NEXT_HDR_LAST_IN2, PROTO_ID_INVALID;
				set %PROTO_SLOT_NEXT 0, IPV4_IN0, IPV4_IN1, IPV4_IN2, PROTO_ID_INVALID;
				set %W2_OFFSET 0;
				set %S6 43;
				set %S5 97;
				alu 0 { ADD %HO, (%W2 & 'h0F) << 2 + 0; }
				alu 1 { NOP; }
			}

		}

		}
	}
	stage 10 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();
		@0 { 'h????, 'h????, 'h??, 18, 'h??, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_UDP_Depth0 */
				set %PROTO_SLOT_NEXT 0, UDP_IN0, UDP_IN1, UDP_IN2, PROTO_ID_INVALID;
				set %PROTO_SLOT_NEXT 0, L4_IN0, L4_IN1, PROTO_ID_INVALID, PROTO_ID_INVALID;
				set %W0_OFFSET 2;
				set %S6 44;
				set %S5 84;
				alu 0 { ADD %HO, 8; }
				alu 1 { NOP; }
			}

		}
		@1 { 'h????, 'h????, 'h??, 19, 'h??, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_IPv4_Depth1 */
				set %MARKER2 1;
				set %W0_OFFSET 0;
				set %WAY_SEL 1;
				set %S6 21;
				set %S5 112;
				alu 0 { NOP; }
				alu 1 { NOP; }
			}

		}

		}
	}
	stage 11 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();
		@0 { 'hB512, 'h????, 'h??, 44, 'h54, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_VXLAN_Depth0 */
				set %PACKET_FLAG_20 0;
				set %PACKET_FLAG_21 1;
				set %MARKER6 1;
				set %PROTO_SLOT_NEXT 0, PROTO_ID_INVALID, VXLAN_IN1, VXLAN_IN2, PROTO_ID_INVALID;
				set %PROTO_SLOT_NEXT 4, GENTUN_IN0, GENTUN_IN0, GENTUN_IN0, PROTO_ID_INVALID;
				set %S6 22;
				set %S5 80;
				alu 0 { ADD %HO, 8; }
				alu 1 { NOP; }
			}

		}
		@1 { 'hC117, 'h????, 'h??, 44, 'h54, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_GENEVE_Depth0 */
				set %MARKER7 1;
				set %PROTO_SLOT_NEXT 0, GENEVE_IN0, GENEVE_IN0, GENEVE_IN0, PROTO_ID_INVALID;
				set %PROTO_SLOT_NEXT 4, GENTUN_IN0, GENTUN_IN0, GENTUN_IN0, PROTO_ID_INVALID;
				set %W0_OFFSET 2;
				set %S6 11;
				set %S5 79;
				alu 0 { ADD %HO, 8; }
				alu 1 { NOP; }
			}

		}

		}
	}
	stage 12 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();
		@0 { 'h5865, 'h????, 'h??, 11, 'h4F, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_MAC_Depth1 */
				set %MARKER0 1;
				set %PROTO_SLOT_NEXT 0, PROTO_ID_INVALID, MAC_IN0, MAC_IN1, PROTO_ID_INVALID;
				set %PROTO_SLOT_NEXT 12, VLAN_ETYPE_START_IN1, VLAN_ETYPE_START_IN1, VLAN_ETYPE_START_IN1, PROTO_ID_INVALID;
				set %W0_OFFSET 12;
				set %WAY_SEL 1;
				set %S6 27;
				set %S5 78;
				alu 0 { ADD %HO, 12; }
				alu 1 { NOP; }
			}

		}
		@1 { 'h0008, 'h????, 'h??, 11, 'h4F, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_IPv4_Depth1 */
				set %MARKER2 1;
				set %W0_OFFSET 0;
				set %WAY_SEL 1;
				set %S6 21;
				set %S5 112;
				alu 0 { NOP; }
				alu 1 { NOP; }
			}

		}
		@2 { 'hDD86, 'h????, 'h??, 11, 'h4F, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_IPv6_Depth1 */
				set %MARKER5 1;
				set %PROTO_SLOT_NEXT 0, PROTO_ID_INVALID, IPV6_IN0, IPV6_IN1, PROTO_ID_INVALID;
				set %W0_OFFSET 6;
				set %WAY_SEL 1;
				set %S6 11;
				set %S5 110;
				alu 0 { ADD %HO, 40; }
				alu 1 { NOP; }
			}

		}
		@3 { 'h????, 'h????, 'h??, 22, 'h??, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_MAC_Depth1 */
				set %MARKER0 1;
				set %PROTO_SLOT_NEXT 0, PROTO_ID_INVALID, MAC_IN0, MAC_IN1, PROTO_ID_INVALID;
				set %PROTO_SLOT_NEXT 12, VLAN_ETYPE_START_IN1, VLAN_ETYPE_START_IN1, VLAN_ETYPE_START_IN1, PROTO_ID_INVALID;
				set %W0_OFFSET 12;
				set %WAY_SEL 1;
				set %S6 27;
				set %S5 78;
				alu 0 { ADD %HO, 12; }
				alu 1 { NOP; }
			}

		}

		}
	}
	stage 13 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();
		@0 { 'h0081, 'h????, 'h??, 27, 'h4E, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_CTag_Depth1 */
				set %PROTO_SLOT_NEXT 0, PROTO_ID_INVALID, VLAN_EXT_IN0, VLAN_EXT_IN1, PROTO_ID_INVALID;
				set %W0_OFFSET 4;
				set %S6 27;
				set %S5 77;
				alu 0 { ADD %HO, 4; }
				alu 1 { NOP; }
			}

		}
		@1 { 'hA888, 'h????, 'h??, 27, 'h4E, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_STag_Depth1 */
				set %PROTO_SLOT_NEXT 0, PROTO_ID_INVALID, VLAN_EXT_IN0, VLAN_EXT_IN1, PROTO_ID_INVALID;
				set %W0_OFFSET 4;
				set %S6 27;
				set %S5 77;
				alu 0 { ADD %HO, 4; }
				alu 1 { NOP; }
			}

		}

		}
	}
	stage 14 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();
		@0 { 'h0081, 'h????, 'h??, 27, 'h4D, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_CTag_DoubleVLAN_Depth1 */
				set %PROTO_SLOT_NEXT 0, PROTO_ID_INVALID, VLAN_INT_IN0, VLAN_INT_IN1, PROTO_ID_INVALID;
				set %PROTO_SLOT_26 4, PROTO_ID_INVALID, ETYPE_IN0, ETYPE_IN1, PROTO_ID_INVALID;
				set %S6 27;
				set %S5 75;
				alu 0 { ADD %HO, 6; }
				alu 1 { NOP; }
			}

		}

		}
	}
	stage 15 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();
		@0 { 'h????, 'h????, 'h??, 27, 'h??, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_ETYPE_Depth1 */
				set %PROTO_SLOT_26 0, PROTO_ID_INVALID, ETYPE_IN0, ETYPE_IN1, PROTO_ID_INVALID;
				set %W0_OFFSET 0;
				set %S6 11;
				set %S5 74;
				alu 0 { ADD %HO, 2; }
				alu 1 { NOP; }
			}

		}

		}
	}
	stage 16 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();
		@0 { 'h0008, 'h????, 'h??, 11, 'h4A, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_IPv4_Depth1 */
				set %MARKER2 1;
				set %W0_OFFSET 0;
				set %WAY_SEL 1;
				set %S6 21;
				set %S5 112;
				alu 0 { NOP; }
				alu 1 { NOP; }
			}

		}
		@1 { 'hDD86, 'h????, 'h??, 11, 'h4A, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_IPv6_Depth1 */
				set %MARKER5 1;
				set %PROTO_SLOT_NEXT 0, PROTO_ID_INVALID, IPV6_IN0, IPV6_IN1, PROTO_ID_INVALID;
				set %W0_OFFSET 6;
				set %WAY_SEL 1;
				set %S6 11;
				set %S5 110;
				alu 0 { ADD %HO, 40; }
				alu 1 { NOP; }
			}

		}
		@2 { 'h0608, 'h????, 'h??, 11, 'h4A, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_ARP */
				set %NODEID 1;
				set %PROTO_SLOT_NEXT 0, ARP, ARP, ARP, PROTO_ID_INVALID;
				set %PROTO_SLOT_NEXT 28, PAY, PAY, PAY, PAY;
				set %FLAG_DONE 1;
				set %S6 10;
				set %S5 118;
				alu 0 { NOP; }
				alu 1 { NOP; }
			}

		}

		}
	}
	stage 17 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();
		@0 { 'b????_????_????_00??, 'h????, 'h??, 21, 'h70, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_Hdr_Too_Short */
				set %PACKET_FLAG_17 1;
				set %S6 11;
				set %S5 117;
				alu 0 { NOP; }
				alu 1 { NOP; }
			}

		}
		@1 { 'h???4, 'h????, 'h??, 21, 'h70, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_Hdr_Too_Short */
				set %PACKET_FLAG_17 1;
				set %S6 11;
				set %S5 117;
				alu 0 { NOP; }
				alu 1 { NOP; }
			}

		}
		@2 { 'h??11, 'h????, 'h??, 11, 'h6E, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_UDP_Depth1 */
				set %PROTO_SLOT_NEXT 0, PROTO_ID_INVALID, UDP_IN0, UDP_IN1, PROTO_ID_INVALID;
				set %PROTO_SLOT_27 0, PROTO_ID_INVALID, L4_IN0, PROTO_ID_INVALID, PROTO_ID_INVALID;
				set %S6 44;
				set %S5 83;
				alu 0 { ADD %HO, 8; }
				alu 1 { NOP; }
			}

		}
		@3 { 'h??06, 'h????, 'h??, 11, 'h6E, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_TCP */
				set %W0_OFFSET 12;
				set %S6 14;
				set %S5 93;
				alu 0 { NOP; }
				alu 1 { NOP; }
			}

		}
		@4 { 'h??3A, 'h????, 'h??, 11, 'h6E, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_icmpv6 */
				set %NODEID 6;
				set %W0_OFFSET 0;
				set %S6 11;
				set %S5 103;
				alu 0 { ADD %HO, 4; }
				alu 1 { NOP; }
			}

		}
		@5 { 'h????, 'h????, 'h??, 21, 'h??, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_IPv4_Check_Frag_Depth1 */
				set %W0_OFFSET 6;
				set %S6 32;
				set %S5 108;
				alu 0 { NOP; }
				alu 1 { NOP; }
			}

		}

		}
	}
	stage 18 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();
		@0 { 'b0000_0000_??00_0000, 'h????, 'h??, 32, 'h6C, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_IPv4_NextProto_Depth1 */
				set %PROTO_SLOT_NEXT 9, PROTO_ID_INVALID, IP_NEXT_HDR_LAST_IN0, IP_NEXT_HDR_LAST_IN1, PROTO_ID_INVALID;
				set %PROTO_SLOT_NEXT 0, PROTO_ID_INVALID, IPV4_IN0, IPV4_IN1, PROTO_ID_INVALID;
				set %W0_OFFSET 9;
				set %W2_OFFSET 0;
				set %S6 39;
				set %S5 105;
				alu 0 { ADD %HO, (%W2 & 'h0F) << 2 + 0; }
				alu 1 { NOP; }
			}

		}
		@1 { 'b0000_0000_??10_0000, 'h????, 'h??, 32, 'h6C, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_IPv4_Frag_Head_Depth1 */
				set %PACKET_FLAG_18 1;
				set %S6 32;
				set %S5 99;
				alu 0 { NOP; }
				alu 1 { NOP; }
			}

		}
		@2 { 'h??87, 'h????, 'h??, 11, 'h67, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_icmpv6_ns */
				set %PACKET_FLAG_26 1;
				set %S6 11;
				set %S5 102;
				alu 0 { NOP; }
				alu 1 { NOP; }
			}

		}
		@3 { 'h??88, 'h????, 'h??, 11, 'h67, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_icmpv6_na */
				set %PACKET_FLAG_27 1;
				set %S6 11;
				set %S5 101;
				alu 0 { NOP; }
				alu 1 { NOP; }
			}

		}

		}
	}
	stage 19 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();
		@0 { 'h??11, 'h????, 'h??, 39, 'h69, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_UDP_Depth1_delay */
				set %S6 35;
				set %S5 68;
				alu 0 { NOP; }
				alu 1 { NOP; }
			}

		}
		@1 { 'h??06, 'h????, 'h??, 39, 'h69, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_TCP */
				set %W0_OFFSET 12;
				set %S6 14;
				set %S5 93;
				alu 0 { NOP; }
				alu 1 { NOP; }
			}

		}
		@2 { 'h??04, 'h????, 'h??, 39, 'h69, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_IPV4_In_IPV4_Depth2 */
				set %PACKET_FLAG_20 1;
				set %PACKET_FLAG_21 1;
				set %MARKER3 1;
				set %W0_OFFSET 0;
				set %WAY_SEL 2;
				set %S6 36;
				set %S5 114;
				alu 0 { NOP; }
				alu 1 { NOP; }
			}

		}
		@3 { 'h????, 'h????, 'h??, 32, 'h??, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_IPv4_Frag_Depth1 */
				set %PROTO_SLOT_NEXT 9, PROTO_ID_INVALID, IP_NEXT_HDR_LAST_IN0, IP_NEXT_HDR_LAST_IN1, PROTO_ID_INVALID;
				set %PROTO_SLOT_NEXT 0, PROTO_ID_INVALID, IPV4_IN0, IPV4_IN1, PROTO_ID_INVALID;
				set %W2_OFFSET 0;
				set %S6 43;
				set %S5 96;
				alu 0 { ADD %HO, (%W2 & 'h0F) << 2 + 0; }
				alu 1 { NOP; }
			}

		}

		}
	}
	stage 20 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();
		@0 { 'b????_????_????_00??, 'h????, 'h??, 36, 'h72, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_Hdr_Too_Short */
				set %PACKET_FLAG_17 1;
				set %S6 11;
				set %S5 117;
				alu 0 { NOP; }
				alu 1 { NOP; }
			}

		}
		@1 { 'h???4, 'h????, 'h??, 36, 'h72, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_Hdr_Too_Short */
				set %PACKET_FLAG_17 1;
				set %S6 11;
				set %S5 117;
				alu 0 { NOP; }
				alu 1 { NOP; }
			}

		}
		@2 { 'h????, 'h????, 'h??, 36, 'h??, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_IPv4_Check_Frag_Depth2 */
				set %W0_OFFSET 6;
				set %S6 40;
				set %S5 107;
				alu 0 { NOP; }
				alu 1 { NOP; }
			}

		}
		@3 { 'h????, 'h????, 'h??, 35, 'h??, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_UDP_Depth1 */
				set %PROTO_SLOT_NEXT 0, PROTO_ID_INVALID, UDP_IN0, UDP_IN1, PROTO_ID_INVALID;
				set %PROTO_SLOT_27 0, PROTO_ID_INVALID, L4_IN0, PROTO_ID_INVALID, PROTO_ID_INVALID;
				set %S6 44;
				set %S5 83;
				alu 0 { ADD %HO, 8; }
				alu 1 { NOP; }
			}

		}

		}
	}
	stage 21 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();
		@0 { 'b0000_0000_??00_0000, 'h????, 'h??, 40, 'h6B, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_IPv4_NextProto_Depth2 */
				set %PROTO_SLOT_NEXT 0, PROTO_ID_INVALID, PROTO_ID_INVALID, IPV4_IN0, PROTO_ID_INVALID;
				set %W0_OFFSET 9;
				set %W2_OFFSET 0;
				set %S6 39;
				set %S5 104;
				alu 0 { ADD %HO, (%W2 & 'h0F) << 2 + 0; }
				alu 1 { NOP; }
			}

		}
		@1 { 'b0000_0000_??10_0000, 'h????, 'h??, 40, 'h6B, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_IPv4_Frag_Head_Depth2 */
				set %PACKET_FLAG_18 1;
				set %S6 40;
				set %S5 98;
				alu 0 { NOP; }
				alu 1 { NOP; }
			}

		}

		}
	}
	stage 22 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();
		@0 { 'h??11, 'h????, 'h??, 39, 'h68, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_UDP_Depth2_delay */
				set %S6 41;
				set %S5 67;
				alu 0 { NOP; }
				alu 1 { NOP; }
			}

		}
		@1 { 'h??06, 'h????, 'h??, 39, 'h68, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_TCP */
				set %W0_OFFSET 12;
				set %S6 14;
				set %S5 93;
				alu 0 { NOP; }
				alu 1 { NOP; }
			}

		}
		@2 { 'h????, 'h????, 'h??, 39, 'h??, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_PAY_delay */
				set %S6 11;
				set %S5 71;
				alu 0 { NOP; }
				alu 1 { NOP; }
			}

		}
		@3 { 'h????, 'h????, 'h??, 40, 'h??, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_IPv4_Frag_Depth2 */
				set %PROTO_SLOT_NEXT 0, PROTO_ID_INVALID, PROTO_ID_INVALID, IPV4_IN0, PROTO_ID_INVALID;
				set %W2_OFFSET 0;
				set %S6 43;
				set %S5 95;
				alu 0 { ADD %HO, (%W2 & 'h0F) << 2 + 0; }
				alu 1 { NOP; }
			}

		}

		}
	}
	stage 23 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();
		@0 { 'b????_????_00??_????, 'h????, 'h??, 14, 'h5D, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_Hdr_Too_Short */
				set %PACKET_FLAG_17 1;
				set %S6 11;
				set %S5 117;
				alu 0 { NOP; }
				alu 1 { NOP; }
			}

		}
		@1 { 'h??4?, 'h????, 'h??, 14, 'h5D, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_Hdr_Too_Short */
				set %PACKET_FLAG_17 1;
				set %S6 11;
				set %S5 117;
				alu 0 { NOP; }
				alu 1 { NOP; }
			}

		}
		@2 { 'b????_??01_????_????, 'h????, 'h??, 14, 'h5D, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_TCP_FIN */
				set %PACKET_FLAG_23 1;
				set %PROTO_SLOT_NEXT 0, TCP, TCP, TCP, PROTO_ID_INVALID;
				set %PROTO_SLOT_27 0, L4_IN0, L4_IN0, PROTO_ID_INVALID, PROTO_ID_INVALID;
				set %W0_OFFSET 13;
				set %W2_OFFSET 12;
				set %S6 45;
				set %S5 92;
				alu 0 { ADD %HO, (%W2 & 'hF0) >> 2 + 0; }
				alu 1 { NOP; }
			}

		}
		@3 { 'b????_??10_????_????, 'h????, 'h??, 14, 'h5D, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_TCP_SYN */
				set %PACKET_FLAG_22 1;
				set %PROTO_SLOT_NEXT 0, TCP, TCP, TCP, PROTO_ID_INVALID;
				set %PROTO_SLOT_27 0, L4_IN0, L4_IN0, PROTO_ID_INVALID, PROTO_ID_INVALID;
				set %W0_OFFSET 13;
				set %W2_OFFSET 12;
				set %S6 45;
				set %S5 92;
				alu 0 { ADD %HO, (%W2 & 'hF0) >> 2 + 0; }
				alu 1 { NOP; }
			}

		}
		@4 { 'b????_??11_????_????, 'h????, 'h??, 14, 'h5D, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_TCP_FIN_SYN */
				set %PACKET_FLAG_23 1;
				set %PACKET_FLAG_22 1;
				set %PROTO_SLOT_NEXT 0, TCP, TCP, TCP, PROTO_ID_INVALID;
				set %PROTO_SLOT_27 0, L4_IN0, L4_IN0, PROTO_ID_INVALID, PROTO_ID_INVALID;
				set %W0_OFFSET 13;
				set %W2_OFFSET 12;
				set %S6 45;
				set %S5 92;
				alu 0 { ADD %HO, (%W2 & 'hF0) >> 2 + 0; }
				alu 1 { NOP; }
			}

		}
		@5 { 'h????, 'h????, 'h??, 14, 'h??, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_TCP_No_FIN_SYN */
				set %PROTO_SLOT_NEXT 0, TCP, TCP, TCP, PROTO_ID_INVALID;
				set %PROTO_SLOT_27 0, L4_IN0, L4_IN0, PROTO_ID_INVALID, PROTO_ID_INVALID;
				set %W0_OFFSET 13;
				set %W2_OFFSET 12;
				set %S6 45;
				set %S5 92;
				alu 0 { ADD %HO, (%W2 & 'hF0) >> 2 + 0; }
				alu 1 { NOP; }
			}

		}
		@6 { 'h????, 'h????, 'h??, 43, 'h??, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_IP_Frag */
				set %PACKET_FLAG_19 1;
				set %S6 11;
				set %S5 94;
				alu 0 { NOP; }
				alu 1 { NOP; }
			}

		}
		@7 { 'h????, 'h????, 'h??, 41, 'h??, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_UDP_Depth2 */
				set %PROTO_SLOT_NEXT 0, PROTO_ID_INVALID, PROTO_ID_INVALID, UDP_IN0, PROTO_ID_INVALID;
				set %S6 44;
				set %S5 82;
				alu 0 { ADD %HO, 8; }
				alu 1 { NOP; }
			}

		}

		}
	}
	stage 24 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();
		@0 { 'b????_????_???0_?1??, 'h????, 'h??, 45, 'h5C, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_TCP_RST */
				set %PACKET_FLAG_24 1;
				set %S6 48;
				set %S5 88;
				alu 0 { NOP; }
				alu 1 { NOP; }
			}

		}
		@1 { 'b????_????_???1_?0??, 'h????, 'h??, 45, 'h5C, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_TCP_ACK */
				set %PACKET_FLAG_25 1;
				set %S6 48;
				set %S5 87;
				alu 0 { NOP; }
				alu 1 { NOP; }
			}

		}
		@2 { 'b????_????_???1_?1??, 'h????, 'h??, 45, 'h5C, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_TCP_RST_ACK */
				set %PACKET_FLAG_24 1;
				set %PACKET_FLAG_25 1;
				set %S6 48;
				set %S5 86;
				alu 0 { NOP; }
				alu 1 { NOP; }
			}

		}
		@3 { 'h????, 'h????, 'h??, 45, 'h??, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_TCP_Pay_delay */
				set %S6 48;
				set %S5 70;
				alu 0 { NOP; }
				alu 1 { NOP; }
			}

		}
		@4 { 'h????, 'h????, 'h??, 11, 'h??, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_PAY */
				set %NODEID 4;
				set %PROTO_SLOT_NEXT 0, PAY, PAY, PAY, PAY;
				set %FLAG_DONE 1;
				set %S6 52;
				set %S5 116;
				alu 0 { NOP; }
				alu 1 { NOP; }
			}

		}
		@5 { 'h????, 'h????, 'h??, 44, 'h??, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_UDP_PAY */
				set %NODEID 3;
				set %PROTO_SLOT_NEXT 0, PAY, PAY, PAY, PAY;
				set %FLAG_DONE 1;
				set %S6 47;
				set %S5 81;
				alu 0 { NOP; }
				alu 1 { NOP; }
			}

		}

		}
	}
	stage 25 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();
		@0 { 'h????, 'h????, 'h??, 48, 'h??, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: Parse_TCP_Pay */
				set %NODEID 2;
				set %PROTO_SLOT_NEXT 0, PAY, PAY, PAY, PAY;
				set %FLAG_DONE 1;
				set %S6 53;
				set %S5 85;
				alu 0 { NOP; }
				alu 1 { NOP; }
			}

		}
		@1 { 'h????, 'h????, 'h??, 'h??, 'h??, 'h??, 'h??, 'h??, 'h??, 'h??			
			{ /* State: reject */
				set %NODEID 7;
				set %MARKERS 0;
				set %FLAG_DONE 1;
				set %S5 72;
				alu 0 { NOP; }
				alu 1 { NOP; }
			}

		}

		}
	}
	stage 26 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();

		}
	}
	stage 27 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();

		}
	}
	stage 28 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();

		}
	}
	stage 29 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();

		}
	}
	stage 30 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();

		}
	}
	stage 31 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();

		}
	}
	stage 32 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();

		}
	}
	stage 33 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();

		}
	}
	stage 34 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();

		}
	}
	stage 35 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();

		}
	}
	stage 36 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();

		}
	}
	stage 37 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();

		}
	}
	stage 38 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();

		}
	}
	stage 39 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();

		}
	}
	stage 40 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();

		}
	}
	stage 41 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();

		}
	}
	stage 42 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();

		}
	}
	stage 43 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();

		}
	}
	stage 44 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();

		}
	}
	stage 45 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();

		}
	}
	stage 46 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();

		}
	}
	stage 47 {

		tmem RULES(%W0, %W1, %S7, %S6, %S5, %S4, %S3, %S2, %S1, %S0) {
			default();

		}
	}
}


block SEM {

  domain GLOBAL {

    owner PROFILE_CFG 0..15 GLOBAL;
    owner PROFILE 12..1023 GLOBAL;
    owner OBJECT_CACHE_CFG 0..5 GLOBAL;
    owner CACHE_BANK 0..5 GLOBAL;
    owner PROFILE 4095..4095 GLOBAL;
    owner PROFILE_CFG 0 GLOBAL;

    tcam MD_PRE_EXTRACT(%TX, %PTYPE) {

        1, 'b??_????_???? : %NULL, %NULL, %NULL, %NULL;
        0, 'b??_????_???? : %MD4[7:0], %NULL, %NULL, %NULL;
    }


    tcam SEM_MD2(%MD_PRE_EXTRACT, %FLAGS[15:0], %PARSER_FLAGS[39:8]) {
            'h????_????, 16'b????_????_????_???1, 32'b????_????_????_????_????_????_????_???? : BASE(0), KEY(45), KEY(44), KEY(33), KEY(32);
            'h????_????, 16'b????_????_????_???0, 32'b????_????_????_????_????_????_????_???? : BASE(0), KEY(48), KEY(45), KEY(44), KEY(33), KEY(32);

    }

    table PTYPE_GROUP(%PTYPE) {

        255 : 255, DROP(0);
        1 : 1, DROP(0);
        11 : 11, DROP(0);
        23 : 23, DROP(0);
        24 : 24, DROP(0);
        26 : 26, DROP(0);
        58 : 58, DROP(0);
        287 : 287, DROP(0);
        60 : 60, DROP(0);
        61 : 61, DROP(0);
        63 : 63, DROP(0);
    }

    tcam PROFILE(%PTYPE_GROUP, %VSI_GROUP, %SEM_MD2, %PORT) {

        @12 { 26, 'b???_????_????, 'b????_????_???1_10?0, 'b?? : 1; }
        @13 { 63, 'b???_????_????, 'b????_????_???1_10?0, 'b?? : 1; }
        @4095 { 'b??_????_????, 'b???_????_????, 'h????, 'b?? : 0; }
    }

    table OBJECT_CACHE_CFG(%OBJECT_ID) {

        0 : BASE(0), ENTRY_SIZE(32), START_BANK(0), NUM_BANKS(1);
    }

    table PROFILE_CFG(%PROFILE) {

        1 : SWID_SRC(DERIVE), COMPRESS_KEY(0), AUX_PREC(0), HASH_SIZE0(12), HASH_SIZE1(9), HASH_SIZE2(8), HASH_SIZE3(7), HASH_SIZE4(6), HASH_SIZE5(5), PINNED_LOOKUP(0), AGING_MODE(NONE), 
			// trap_table
			LUT {
				OBJECT_ID(0),
				VSI_LIST_EN(1),
				INV_ACTION(0),
				NUM_ACTIONS(1),
				MISS_ACTION0(3825336329),
				EXTRACT {
					WORD0 (228, 0, 'h1),
					WORD1 (228, 1, 'hFFFF)
				}

			}
, 
			// empty_sem_0
			LUT {
				OBJECT_ID(0),
				VSI_LIST_EN(0),
				INV_ACTION(0),
				NUM_ACTIONS(1)
			}
, 
			// empty_sem_0
			LUT {
				OBJECT_ID(0),
				VSI_LIST_EN(0),
				INV_ACTION(0),
				NUM_ACTIONS(1)
			}
, 
			// empty_sem_0
			LUT {
				OBJECT_ID(0),
				VSI_LIST_EN(0),
				INV_ACTION(0),
				NUM_ACTIONS(1)
			}
;
        0 : SWID_SRC(0), COMPRESS_KEY(0), AUX_PREC(0), HASH_SIZE0(1), HASH_SIZE1(1), HASH_SIZE2(1), HASH_SIZE3(1), HASH_SIZE4(1), HASH_SIZE5(1), PINNED_LOOKUP(0), AGING_MODE(NONE), 
			// compiler_internal_sem_bypass
			LUT {
				OBJECT_ID(0),
				VSI_LIST_EN(0),
				INV_ACTION(0),
				NUM_ACTIONS(1)
			}
, 
			// compiler_internal_sem_bypass
			LUT {
				OBJECT_ID(0),
				VSI_LIST_EN(0),
				INV_ACTION(0),
				NUM_ACTIONS(1)
			}
, 
			// compiler_internal_sem_bypass
			LUT {
				OBJECT_ID(0),
				VSI_LIST_EN(0),
				INV_ACTION(0),
				NUM_ACTIONS(1)
			}
, 
			// compiler_internal_sem_bypass
			LUT {
				OBJECT_ID(0),
				VSI_LIST_EN(0),
				INV_ACTION(0),
				NUM_ACTIONS(1)
			}
;
    }

  }
}

block LEM {

  domain GLOBAL {

    owner PROFILE_CFG 0..100 GLOBAL;
    owner OBJECT_CACHE_CFG 0..3 GLOBAL;
    owner HASH_SPACE_CFG 0 GLOBAL;
    owner CACHE_BANK 0..5 GLOBAL;
    owner PROFILE_CFG 0 GLOBAL;
    table OBJECT_CACHE_CFG(%OBJECT_ID) {
		0 : 
			ENTRY_SIZE(64), 
			START_BANK(0), 
			NUM_BANKS(1);

    }
    table PROFILE_CFG(%PROFILE) {
		10 : 
			AUTO_INSERT(ON_MISS), 
			PINNED(0), 
			HASH_SIZE0(12), 
			HASH_SIZE1(9), 
			HASH_SIZE2(8), 
			HASH_SIZE3(7), 
			HASH_SIZE4(6), 
			HASH_SIZE5(5), 
			AUX_PREC(0), 
			AGING_MODE(TIME), 
			PROFILE_GROUP(10), 
			LUT {
				NUM_ACTIONS(0), 
				OBJECT_ID(0), 
				EXTRACT {
					WORD0(32, 12, 'hFFFF), 
					WORD1(32, 14, 'hFFFF), 
					WORD2(32, 16, 'hFFFF), 
					WORD3(32, 18, 'hFFFF), 
					WORD4(32, 9, 'hFF), 
					WORD5(49, 0, 'hFFFF), 
					WORD6(49, 2, 'hFFFF)
				}
			};
		11 : 
			AUTO_INSERT(ON_MISS), 
			PINNED(0), 
			HASH_SIZE0(12), 
			HASH_SIZE1(9), 
			HASH_SIZE2(8), 
			HASH_SIZE3(7), 
			HASH_SIZE4(6), 
			HASH_SIZE5(5), 
			AUX_PREC(0), 
			AGING_MODE(NONE), 
			PROFILE_GROUP(10), 
			LUT {
				NUM_ACTIONS(0), 
				OBJECT_ID(0), 
				EXTRACT {
					WORD0(32, 12, 'hFFFF), 
					WORD1(32, 14, 'hFFFF), 
					WORD2(32, 16, 'hFFFF), 
					WORD3(32, 18, 'hFFFF), 
					WORD4(32, 9, 'hFF), 
					WORD5(49, 0, 'hFFFF), 
					WORD6(49, 2, 'hFFFF)
				}
			};
		12 : 
			AUTO_INSERT(NONE), 
			PINNED(0), 
			HASH_SIZE0(12), 
			HASH_SIZE1(9), 
			HASH_SIZE2(8), 
			HASH_SIZE3(7), 
			HASH_SIZE4(6), 
			HASH_SIZE5(5), 
			AUX_PREC(0), 
			AGING_MODE(TIME), 
			PROFILE_GROUP(10), 
			LUT {
				NUM_ACTIONS(0), 
				OBJECT_ID(0), 
				MISS_ACTION0(3825336321), 
				MISS_ACTION1(3918069760), 
				MISS_ACTION2(536876032), 
				MISS_ACTION3(3925933824), 
				MISS_ACTION4(536876288), 
				MISS_ACTION5(3942711040), 
				MISS_ACTION6(3968532480), 
				EXTRACT {
					WORD0(32, 12, 'hFFFF), 
					WORD1(32, 14, 'hFFFF), 
					WORD2(32, 16, 'hFFFF), 
					WORD3(32, 18, 'hFFFF), 
					WORD4(32, 9, 'hFF), 
					WORD5(49, 0, 'hFFFF), 
					WORD6(49, 2, 'hFFFF)
				}
			};
		13 : 
			AUTO_INSERT(NONE), 
			PINNED(0), 
			HASH_SIZE0(12), 
			HASH_SIZE1(9), 
			HASH_SIZE2(8), 
			HASH_SIZE3(7), 
			HASH_SIZE4(6), 
			HASH_SIZE5(5), 
			AUX_PREC(0), 
			AGING_MODE(NONE), 
			PROFILE_GROUP(10), 
			LUT {
				NUM_ACTIONS(0), 
				OBJECT_ID(0), 
				MISS_ACTION0(3825336321), 
				MISS_ACTION1(3918069760), 
				MISS_ACTION2(536876032), 
				MISS_ACTION3(3925933824), 
				MISS_ACTION4(536876288), 
				MISS_ACTION5(3942711040), 
				MISS_ACTION6(3968532480), 
				EXTRACT {
					WORD0(32, 12, 'hFFFF), 
					WORD1(32, 14, 'hFFFF), 
					WORD2(32, 16, 'hFFFF), 
					WORD3(32, 18, 'hFFFF), 
					WORD4(32, 9, 'hFF), 
					WORD5(49, 0, 'hFFFF), 
					WORD6(49, 2, 'hFFFF)
				}
			};
		14 : 
			AUTO_INSERT(ON_MISS), 
			PINNED(0), 
			HASH_SIZE0(12), 
			HASH_SIZE1(9), 
			HASH_SIZE2(8), 
			HASH_SIZE3(7), 
			HASH_SIZE4(6), 
			HASH_SIZE5(5), 
			AUX_PREC(0), 
			AGING_MODE(TIME), 
			PROFILE_GROUP(10), 
			LUT {
				NUM_ACTIONS(0), 
				OBJECT_ID(0), 
				EXTRACT {
					WORD0(32, 16, 'hFFFF), 
					WORD1(32, 18, 'hFFFF), 
					WORD2(32, 12, 'hFFFF), 
					WORD3(32, 14, 'hFFFF), 
					WORD4(32, 9, 'hFF), 
					WORD5(49, 2, 'hFFFF), 
					WORD6(49, 0, 'hFFFF)
				}
			};
		15 : 
			AUTO_INSERT(ON_MISS), 
			PINNED(0), 
			HASH_SIZE0(12), 
			HASH_SIZE1(9), 
			HASH_SIZE2(8), 
			HASH_SIZE3(7), 
			HASH_SIZE4(6), 
			HASH_SIZE5(5), 
			AUX_PREC(0), 
			AGING_MODE(NONE), 
			PROFILE_GROUP(10), 
			LUT {
				NUM_ACTIONS(0), 
				OBJECT_ID(0), 
				EXTRACT {
					WORD0(32, 16, 'hFFFF), 
					WORD1(32, 18, 'hFFFF), 
					WORD2(32, 12, 'hFFFF), 
					WORD3(32, 14, 'hFFFF), 
					WORD4(32, 9, 'hFF), 
					WORD5(49, 2, 'hFFFF), 
					WORD6(49, 0, 'hFFFF)
				}
			};
		16 : 
			AUTO_INSERT(NONE), 
			PINNED(0), 
			HASH_SIZE0(12), 
			HASH_SIZE1(9), 
			HASH_SIZE2(8), 
			HASH_SIZE3(7), 
			HASH_SIZE4(6), 
			HASH_SIZE5(5), 
			AUX_PREC(0), 
			AGING_MODE(TIME), 
			PROFILE_GROUP(10), 
			LUT {
				NUM_ACTIONS(0), 
				OBJECT_ID(0), 
				MISS_ACTION0(3825369089), 
				EXTRACT {
					WORD0(32, 16, 'hFFFF), 
					WORD1(32, 18, 'hFFFF), 
					WORD2(32, 12, 'hFFFF), 
					WORD3(32, 14, 'hFFFF), 
					WORD4(32, 9, 'hFF), 
					WORD5(49, 2, 'hFFFF), 
					WORD6(49, 0, 'hFFFF)
				}
			};
		17 : 
			AUTO_INSERT(NONE), 
			PINNED(0), 
			HASH_SIZE0(12), 
			HASH_SIZE1(9), 
			HASH_SIZE2(8), 
			HASH_SIZE3(7), 
			HASH_SIZE4(6), 
			HASH_SIZE5(5), 
			AUX_PREC(0), 
			AGING_MODE(NONE), 
			PROFILE_GROUP(10), 
			LUT {
				NUM_ACTIONS(0), 
				OBJECT_ID(0), 
				MISS_ACTION0(3825369089), 
				EXTRACT {
					WORD0(32, 16, 'hFFFF), 
					WORD1(32, 18, 'hFFFF), 
					WORD2(32, 12, 'hFFFF), 
					WORD3(32, 14, 'hFFFF), 
					WORD4(32, 9, 'hFF), 
					WORD5(49, 2, 'hFFFF), 
					WORD6(49, 0, 'hFFFF)
				}
			};
		0 : 
			HASH_SIZE0(1), 
			HASH_SIZE1(1), 
			HASH_SIZE2(1), 
			HASH_SIZE3(1), 
			HASH_SIZE4(1), 
			HASH_SIZE5(1), 
			LUT {
				NUM_ACTIONS(0), 
				KEY_SIZE(0)
			};

    }
    table HASH_SPACE_CFG(%HASH_SPACE_ID) {
		0 : 
			BASE('h0);

    }
    table AGING_ADDR_CFG(%AGING_TABLE_ID) {
		0 : 
			BASE('h0);
		1 : 
			BASE('h200000);
		2 : 
			BASE('h400000);

    }
    table AGING_TIMER(%TIMER_ID) {
		0 : 
			AGE_TICKS('h20);
		1 : 
			AGE_TICKS('h8);
		2 : 
			AGE_TICKS('h10);
		3 : 
			AGE_TICKS('h18);

    }

  }
}

block HASH {

  domain GLOBAL {

    owner PROFILE 0..127 GLOBAL;
    owner PROFILE_LUT_CFG 0..15 GLOBAL;
    owner KEY_EXTRACT 0..15 GLOBAL;
    owner SYMMETRICIZE 0..15 GLOBAL;
    owner KEY_MASK 0..15 GLOBAL;
    owner PROFILE 4095..4095 GLOBAL;
    owner PROFILE_LUT_CFG 0 GLOBAL;
    owner KEY_EXTRACT 0 GLOBAL;
    owner KEY_MASK 0 GLOBAL;
    tcam MD_EXTRACT(%PTYPE, %MD_DIGEST, %FLAGS[15:0]) {
		'b????_????_??, 'h??, 'b????_????_????_???1 : %NULL_MD_8BIT, %NULL_MD_8BIT, %NULL_MD_8BIT, %NULL_MD_8BIT;
		'b????_????_??, 'h??, 'b????_????_????_???0 : %NULL_MD_8BIT, %NULL_MD_8BIT, %NULL_MD_8BIT, %NULL_MD_8BIT;

    }
    tcam MD_KEY(%PTYPE, %MD_EXTRACT, %FLAGS[15:0], %PARSER_FLAGS[39:8]) {
		'b????_????_??, 'h????_????, 'b????_????_????_???1, 'h????_???? : 
			MASK('hFFFF), 
			KEY(45), 
			KEY(44), 
			KEY(33), 
			KEY(32);
		'b????_????_??, 'h????_????, 'b????_????_????_???0, 'h????_???? : 
			MASK('hFFFF), 
			KEY(45), 
			KEY(44), 
			KEY(33), 
			KEY(32);

    }
    table PTYPE_GROUP(%PTYPE) {
		26 : 1;
		63 : 1;
		24 : 2;
		61 : 2;
		23 : 3;
		60 : 3;

    }
    tcam PROFILE(%PTYPE_GROUP, %VSI_GROUP, %MD_KEY) {
		@0 { 1, 'b????_?, 'b????_????_????_???0 : 1; }
		@1 { 2, 'b????_?, 'b????_????_????_???0 : 2; }
		@2 { 3, 'b????_?, 'b????_????_????_???0 : 3; }
		@4095 { 'b????, 'b????_?, 'h???? : 0; }

    }

    define LUT pna_connection_track_control_rss_hash_tcp_lut {
		BASE('h0),
		SIZE('h80)
    }

    define LUT pna_connection_track_control_rss_hash_udp_lut {
		BASE('h80),
		SIZE('h80)
    }

    define LUT pna_connection_track_control_rss_hash_lut {
		BASE('h100),
		SIZE('h80)
    }
    table PROFILE_LUT_CFG(%PROFILE) {
	1 : 
			TYPE(QUEUE), 
			MASK_SELECT(1), 
			TC_OVR(0), 
			VSI_PROFILE_OVR(1);
	2 : 
			TYPE(QUEUE), 
			MASK_SELECT(2), 
			TC_OVR(0), 
			VSI_PROFILE_OVR(1);
	3 : 
			TYPE(QUEUE), 
			MASK_SELECT(3), 
			TC_OVR(0), 
			VSI_PROFILE_OVR(1);
	0 : 
			TYPE(QUEUE), 
			MASK_SELECT(0), 
			TC_OVR(0), 
			VSI_PROFILE_OVR(1);

    }
    table KEY_EXTRACT(%PROFILE) {
		1 : 
			BYTE0(32, 12), 
			BYTE1(32, 13), 
			BYTE2(32, 14), 
			BYTE3(32, 15), 
			BYTE4(32, 16), 
			BYTE5(32, 17), 
			BYTE6(32, 18), 
			BYTE7(32, 19), 
			BYTE8(49, 0), 
			BYTE9(49, 1), 
			BYTE10(49, 2), 
			BYTE11(49, 3);
		2 : 
			BYTE0(32, 12), 
			BYTE1(32, 13), 
			BYTE2(32, 14), 
			BYTE3(32, 15), 
			BYTE4(32, 16), 
			BYTE5(32, 17), 
			BYTE6(32, 18), 
			BYTE7(32, 19), 
			BYTE8(52, 0), 
			BYTE9(52, 1), 
			BYTE10(52, 2), 
			BYTE11(52, 3);
		3 : 
			BYTE0(32, 12), 
			BYTE1(32, 13), 
			BYTE2(32, 14), 
			BYTE3(32, 15), 
			BYTE4(32, 16), 
			BYTE5(32, 17), 
			BYTE6(32, 18), 
			BYTE7(32, 19);
		0 : 
			BYTE0(255, 255), 
			BYTE1(255, 255);

    }
    table KEY_MASK(%MASK_SELECT) {
		1 : 
			BYTE0('hFF), 
			BYTE1('hFF), 
			BYTE2('hFF), 
			BYTE3('hFF), 
			BYTE4('hFF), 
			BYTE5('hFF), 
			BYTE6('hFF), 
			BYTE7('hFF), 
			BYTE8('hFF), 
			BYTE9('hFF), 
			BYTE10('hFF), 
			BYTE11('hFF);
		2 : 
			BYTE0('hFF), 
			BYTE1('hFF), 
			BYTE2('hFF), 
			BYTE3('hFF), 
			BYTE4('hFF), 
			BYTE5('hFF), 
			BYTE6('hFF), 
			BYTE7('hFF), 
			BYTE8('hFF), 
			BYTE9('hFF), 
			BYTE10('hFF), 
			BYTE11('hFF);
		3 : 
			BYTE0('hFF), 
			BYTE1('hFF), 
			BYTE2('hFF), 
			BYTE3('hFF), 
			BYTE4('hFF), 
			BYTE5('hFF), 
			BYTE6('hFF), 
			BYTE7('hFF);
		0 : 
			BYTE0('hFF), 
			BYTE1('hFF);

    }

  }
}

block MOD {

  domain GLOBAL {

    owner PROFILE_CFG 0..15 GLOBAL;
    owner FV_EXTRACT 0..15 GLOBAL;
    table HASH_SPACE_CFG(%HASH_SPACE_ID) {
		0 : 
			BASE('h0);
		1 : 
			BASE('h100000);

    }

	set %CSUM_CONFIG_IPV4_0 IPV4_IN0;
	set %CSUM_CONFIG_IPV4_1 IPV4_IN1;
	set %CSUM_CONFIG_IPV4_2 IPV4_IN2;
	set %CSUM_CONFIG_IPV6_0 IPV6_IN0;
	set %CSUM_CONFIG_IPV6_1 IPV6_IN1;
	set %CSUM_CONFIG_IPV6_2 IPV6_IN2;
	set %CSUM_CONFIG_UDP_0 UDP_IN0;
	set %CSUM_CONFIG_UDP_1 UDP_IN1;
	set %CSUM_CONFIG_UDP_2 UDP_IN2;
	set %CSUM_CONFIG_TCP_0 TCP;
	set %CSUM_CONFIG_RAW_VLAN_EXT_0 VLAN_EXT_IN0;
	set %CSUM_CONFIG_RAW_VLAN_EXT_1 VLAN_EXT_IN1;
	set %CSUM_CONFIG_RAW_VLAN_EXT_2 VLAN_EXT_IN2;
	set %CSUM_CONFIG_RAW_VLAN_INT_0 VLAN_INT_IN0;
	set %CSUM_CONFIG_RAW_VLAN_INT_1 VLAN_INT_IN1;
	set %CSUM_CONFIG_RAW_VLAN_INT_2 VLAN_INT_IN2;
	set %CSUM_CONFIG_RAW_MAC_0 MAC_IN0;
	set %CSUM_CONFIG_RAW_MAC_1 MAC_IN1;
	set %CSUM_CONFIG_RAW_MAC_2 MAC_IN2;
  }
}

block WLPG_PROFILES {

  domain GLOBAL {

    owner WLPG_PROFILE 200 GLOBAL;

	direction RX {
	    set %MISS_LEM_PROF0 0;
	    set %MISS_LEM_PROF1 0;
	    set %MISS_WCM_PROF0 0;
	    set %MISS_WCM_PROF1 0;
	    set %MISS_LPM_PROF 0;
	}

	direction TX {
	    set %MISS_LEM_PROF0 0;
	    set %MISS_LEM_PROF1 0;
	    set %MISS_WCM_PROF0 0;
	    set %MISS_WCM_PROF1 0;
	    set %MISS_LPM_PROF 0;
	}
    table PTYPE_GROUP(%PTYPE) {
		255 : 255;
		1 : 1;
		11 : 11;
		23 : 23;
		24 : 24;
		26 : 26;
		58 : 58;
		287 : 287;
		60 : 60;
		61 : 61;
		63 : 63;

    }
    tcam GEN_MD1(%PTYPE, %FLAGS[15:0], %MD_DIGEST) {
		'b??_????_????, 'b????_????_????_???1, 'h?? : %MD4[7:0], %NULL_MD_8BIT, %NULL_MD_8BIT, %NULL_MD_8BIT;
		'b??_????_????, 'b????_????_????_???0, 'h?? : %MD4[7:0], %NULL_MD_8BIT, %NULL_MD_8BIT, %NULL_MD_8BIT;

    }
    tcam GEN_MD2(%GEN_MD1, %FLAGS[15:0], %PARSER_FLAGS[39:8], %PTYPE) {
		'h????_????, 'b????_????_????_???1, 'h????_????, 'b??_????_???? : 
			BASE('h0), 
			KEY(33), 
			KEY(45), 
			KEY(44), 
			KEY(50), 
			KEY(49), 
			KEY(32);
		'h????_????, 'b????_????_????_???0, 'h????_????, 'b??_????_???? : 
			BASE('h0), 
			KEY(33), 
			KEY(45), 
			KEY(44), 
			KEY(50), 
			KEY(49), 
			KEY(32);

    }
    table WLPG_PROFILE(%PTYPE_GROUP, %VSI_GROUP, %GEN_MD2) {
		26, 2, 0 : 
			LEM_PROF0(0), 
			LEM_PROF1(0), 
			WCM_PROF0(2), 
			WCM_PROF1(0), 
			LPM_PROF(0);
		26, 2, 1 : 
			LEM_PROF0(0), 
			LEM_PROF1(0), 
			WCM_PROF0(2), 
			WCM_PROF1(0), 
			LPM_PROF(0);
		26, 2, 2 : 
			LEM_PROF0(0), 
			LEM_PROF1(0), 
			WCM_PROF0(2), 
			WCM_PROF1(0), 
			LPM_PROF(0);
		26, 2, 3 : 
			LEM_PROF0(0), 
			LEM_PROF1(0), 
			WCM_PROF0(2), 
			WCM_PROF1(0), 
			LPM_PROF(0);
		26, 2, 4 : 
			LEM_PROF0(0), 
			LEM_PROF1(0), 
			WCM_PROF0(2), 
			WCM_PROF1(0), 
			LPM_PROF(0);
		26, 2, 5 : 
			LEM_PROF0(0), 
			LEM_PROF1(0), 
			WCM_PROF0(2), 
			WCM_PROF1(0), 
			LPM_PROF(0);
		26, 2, 6 : 
			LEM_PROF0(0), 
			LEM_PROF1(0), 
			WCM_PROF0(2), 
			WCM_PROF1(0), 
			LPM_PROF(0);
		26, 2, 7 : 
			LEM_PROF0(0), 
			LEM_PROF1(0), 
			WCM_PROF0(2), 
			WCM_PROF1(0), 
			LPM_PROF(0);
		63, 2, 0 : 
			LEM_PROF0(0), 
			LEM_PROF1(0), 
			WCM_PROF0(2), 
			WCM_PROF1(0), 
			LPM_PROF(0);
		63, 2, 1 : 
			LEM_PROF0(0), 
			LEM_PROF1(0), 
			WCM_PROF0(2), 
			WCM_PROF1(0), 
			LPM_PROF(0);
		63, 2, 2 : 
			LEM_PROF0(0), 
			LEM_PROF1(0), 
			WCM_PROF0(2), 
			WCM_PROF1(0), 
			LPM_PROF(0);
		63, 2, 3 : 
			LEM_PROF0(0), 
			LEM_PROF1(0), 
			WCM_PROF0(2), 
			WCM_PROF1(0), 
			LPM_PROF(0);
		63, 2, 4 : 
			LEM_PROF0(0), 
			LEM_PROF1(0), 
			WCM_PROF0(2), 
			WCM_PROF1(0), 
			LPM_PROF(0);
		63, 2, 5 : 
			LEM_PROF0(0), 
			LEM_PROF1(0), 
			WCM_PROF0(2), 
			WCM_PROF1(0), 
			LPM_PROF(0);
		63, 2, 6 : 
			LEM_PROF0(0), 
			LEM_PROF1(0), 
			WCM_PROF0(2), 
			WCM_PROF1(0), 
			LPM_PROF(0);
		63, 2, 7 : 
			LEM_PROF0(0), 
			LEM_PROF1(0), 
			WCM_PROF0(2), 
			WCM_PROF1(0), 
			LPM_PROF(0);
		26, 2, 14 : 
			LEM_PROF0(10), 
			LEM_PROF1(0), 
			WCM_PROF0(2), 
			WCM_PROF1(0), 
			LPM_PROF(0);
		63, 2, 14 : 
			LEM_PROF0(10), 
			LEM_PROF1(0), 
			WCM_PROF0(2), 
			WCM_PROF1(0), 
			LPM_PROF(0);
		26, 2, 10 : 
			LEM_PROF0(11), 
			LEM_PROF1(0), 
			WCM_PROF0(2), 
			WCM_PROF1(0), 
			LPM_PROF(0);
		63, 2, 10 : 
			LEM_PROF0(11), 
			LEM_PROF1(0), 
			WCM_PROF0(2), 
			WCM_PROF1(0), 
			LPM_PROF(0);
		26, 2, 12 : 
			LEM_PROF0(12), 
			LEM_PROF1(0), 
			WCM_PROF0(2), 
			WCM_PROF1(0), 
			LPM_PROF(0);
		63, 2, 12 : 
			LEM_PROF0(12), 
			LEM_PROF1(0), 
			WCM_PROF0(2), 
			WCM_PROF1(0), 
			LPM_PROF(0);
		26, 2, 8 : 
			LEM_PROF0(13), 
			LEM_PROF1(0), 
			WCM_PROF0(2), 
			WCM_PROF1(0), 
			LPM_PROF(0);
		63, 2, 8 : 
			LEM_PROF0(13), 
			LEM_PROF1(0), 
			WCM_PROF0(2), 
			WCM_PROF1(0), 
			LPM_PROF(0);
		26, 2, 15 : 
			LEM_PROF0(14), 
			LEM_PROF1(0), 
			WCM_PROF0(2), 
			WCM_PROF1(0), 
			LPM_PROF(0);
		63, 2, 15 : 
			LEM_PROF0(14), 
			LEM_PROF1(0), 
			WCM_PROF0(2), 
			WCM_PROF1(0), 
			LPM_PROF(0);
		26, 2, 11 : 
			LEM_PROF0(15), 
			LEM_PROF1(0), 
			WCM_PROF0(2), 
			WCM_PROF1(0), 
			LPM_PROF(0);
		63, 2, 11 : 
			LEM_PROF0(15), 
			LEM_PROF1(0), 
			WCM_PROF0(2), 
			WCM_PROF1(0), 
			LPM_PROF(0);
		26, 2, 13 : 
			LEM_PROF0(16), 
			LEM_PROF1(0), 
			WCM_PROF0(2), 
			WCM_PROF1(0), 
			LPM_PROF(0);
		63, 2, 13 : 
			LEM_PROF0(16), 
			LEM_PROF1(0), 
			WCM_PROF0(2), 
			WCM_PROF1(0), 
			LPM_PROF(0);
		26, 2, 9 : 
			LEM_PROF0(17), 
			LEM_PROF1(0), 
			WCM_PROF0(2), 
			WCM_PROF1(0), 
			LPM_PROF(0);
		63, 2, 9 : 
			LEM_PROF0(17), 
			LEM_PROF1(0), 
			WCM_PROF0(2), 
			WCM_PROF1(0), 
			LPM_PROF(0);

    }

  }
}

block WCM {

  domain GLOBAL {

    owner PROFILE_CFG0 0..10 GLOBAL;
    owner KEY_EXTRACT0 0..10 GLOBAL;
    owner ACTION_MAP0 0..10 GLOBAL;
    owner PROFILE_CFG1 1023..1023 GLOBAL;
    owner GRP0_SLICE0 0..7 GLOBAL;
    owner GRP0_SLICE1 0..7 GLOBAL;
    owner GRP0_SLICE2 0..7 GLOBAL;
    owner GRP0_SLICE3 0..7 GLOBAL;
    owner GRP0_SLICE4 0..7 GLOBAL;
    owner GRP0_SLICE5 0..7 GLOBAL;
    owner GRP0_SLICE6 0..7 GLOBAL;
    owner GRP0_SLICE7 0..7 GLOBAL;
    owner PROFILE_CFG0 0 GLOBAL;
    owner PROFILE_CFG1 0 GLOBAL;

    define MAT mat0 {
		START_SLICE('h0),
		KEY_WIDTH('h28),
		START_RULE('h0),
		NUM_RULES('h100),
		PREC('h0),
		KEY_SEL0('h0),
		KEY_SEL1('h2),
		KEY_SEL2('h2),
		KEY_SEL3('h2),
		KEY_SEL4('h2)

    }
    table PROFILE_CFG0(%WCM_PROFILE0) {
		2 : 
			MAT(mat0);
		0 : 
			BYPASS(1);

    }
    table PROFILE_CFG1(%WCM_PROFILE1) {
		0 : 
			BYPASS(1);

    }
    table ACTION_MAP0(%WCM_PROFILE0, %SLICE) {
		2, 0 : 0, 1, 2, 3, 4, 5;

    }
    table KEY_EXTRACT0(%WCM_PROFILE0) {
		2 : 
			WORD0(49, 13);

    }

  }
}

block RC {

  domain GLOBAL {


  }
}

block LPM {

  domain GLOBAL {

    owner PROFILE_CFG 0..1 GLOBAL;
    owner PROFILE_CFG 0 GLOBAL;
    table PROFILE_CFG(%PROFILE) {
		0 : 
			KEY_SIZE('h0);

    }
    table HASH_SPACE_CFG(%HASH_SPACE_ID) {
		0 : 
			BASE('h0);

    }

  }
}

block MNG {
    define KEY_EXTRACT {
		MAC_DA(1, 0),
		VLAN_TAG(16, 2),
		ETHERTYPE(9, 0),
		ARP_OPER(118, 6),
		ARP_TPA(118, 24),
		TCP_DPORT(49, 2),
		UDP_DPORT(52, 2),
		IPV4_DA(32, 16),
		IPV6_DA(40, 24),
		TCP_SPORT(49, 0),
		UDP_SPORT(52, 0)
    }
}


block PKB_MISC {
	domain 0 {
		set %IPV4_CSUM_IN0 32;
		set %IPV4_CSUM_IN1 33;
		set %IPV4_CSUM_IN2 34;
		set %IPV6_CSUM_IN0 40;
		set %IPV6_CSUM_IN1 41;
		set %IPV6_CSUM_IN2 42;
		set %UDP_CSUM_IN0 52;
		set %UDP_CSUM_IN1 53;
		set %UDP_CSUM_IN2 54;
		set %TCP_CSUM_IN0 49;
		set %IPV4_ICRC_IN0 32;
		set %IPV6_ICRC_IN0 40;
		set %UDP_ICRC_IN0 52;
		set %PAY 15;
	}
}

block RSC_MISC {
	domain 0 {
		set %IPV4_IN0 32;
		set %IPV4_IN1 33;
		set %IPV4_IN2 34;
		set %IPV6_IN0 40;
		set %IPV6_IN1 41;
		set %IPV6_IN2 42;
		set %UDP_IN0 52;
		set %UDP_IN1 53;
		set %UDP_IN2 54;
		set %TCP 49;
		set %VLAN_EXT_IN0 16;
		set %VLAN_EXT_IN1 17;
		set %VLAN_EXT_IN2 18;
		set %VLAN_INT_IN0 19;
		set %VLAN_INT_IN1 20;
		set %VLAN_INT_IN2 21;
		set %MAC_IN0 1;
		set %MAC_IN1 2;
		set %MAC_IN2 3;
		set %PAY 15;
	}
}

block ICE_MISC {
	domain 0 {
		direction TX {
			set %IP_0 32, IS_V4;
			set %IP_1 33, IS_V4;
			set %IP_2 34, IS_V4;
			set %IP_3 40, IS_V6;
			set %IP_4 41, IS_V6;
			set %IP_5 42, IS_V6;
			set %UDP_0 52;
			set %UDP_1 53;
			set %UDP_2 54;
			set %NEXT_HDR_0 36;
			set %NEXT_HDR_1 37;
			set %NEXT_HDR_2 38;
		}
	}
}

block RDMA_MISC {
	domain 0 {
		set %IPV4_IN0 32;
		set %IPV4_IN1 33;
		set %IPV4_IN2 34;
		set %IPV6_IN0 40;
		set %IPV6_IN1 41;
		set %IPV6_IN2 42;
		set %UDP_IN0 52;
		set %TCP 49;
		set %MAC_IN0 1;
		set %MAC_IN1 2;
		set %MAC_IN2 3;
		set %VLAN_INT_IN0 19;
		set %VLAN_EXT_IN0 16;
		set %VLAN_INT_IN1 20;
		set %VLAN_EXT_IN1 17;
		set %PAY 15;
	}
}

block EVMOUT {
	domain 0 {
		set %MAC_IN0 1;
		set %MAC_IN1 2;
		set %MAC_IN2 3;
	}
}

block SCTP_VAL_MISC {
	domain 0 {
		set %IPV4_IN0 32;
		set %IPV4_IN1 33;
		set %IPV4_IN2 34;
		set %IPV6_IN0 40;
		set %IPV6_IN1 41;
		set %IPV6_IN2 42;
	}
}
}
