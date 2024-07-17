#!/bin/bash


printf "\n%-30s\n" '-ACC IDPF PORTS:-'
printf "%s\n" '-------------------------------------------------------------------------'
printf '| %-10s | %-10s | %-10s | %-15s | %-15s |\n' "VSI"  "PORT"  "  NETDEV"  "  MAC"  "  IP"
printf "%s\n" '-------------------------------------------------------------------------'

MACHINE1_IP=100.0.0.100  # Replace with the IP of machine1
MACHINE2_IP=192.168.0.2  # Replace with the IP of machine2

ssh -o LogLevel=quiet -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@${MACHINE1_IP} \
    "ssh -o LogLevel=quiet -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@${MACHINE2_IP} \
    'declare -a idpf_array=() ; \
    idpf_ports=\$(realpath /sys/class/net/*/dev_port | grep  \$(lspci -nnkd 8086:1452 | awk  \"NR==1{print \\\$1}\") | sort) ; \
    for port in \${idpf_ports} ; do \
        netpath=\$(dirname \$port) ; \
        IDPF_NET_NAME=\$(basename \$netpath) ; \
        IDPF_NET_MAC=\$(head \$netpath/address) ; \
        IDPF_NET_IP=\$(ifconfig \${IDPF_NET_NAME} | grep \"inet \" | awk \"{print \\\$2}\") ; \
        IDPF_VSI_ID_HEX=\$(echo \"\${IDPF_NET_MAC}\" | awk -F: \"{print \\\$2}\" | tr \"[:lower:]\" \"[:upper:]\") ; \
        IDPF_VSI_ID_DEC=\$(echo \"ibase=16; \${IDPF_VSI_ID_HEX}\" | bc) ; \
        IDPF_VSI_PORT_DEC=\$((IDPF_VSI_ID_DEC + 16)) ; \
        IDPF_VSI_PORT_HEX=\$(echo \"obase=16 ; \${IDPF_VSI_PORT_DEC}\" | bc) ; \
        arr=(\"\${IDPF_VSI_ID_HEX}\" \"\${IDPF_VSI_ID_DEC}\" \"\${IDPF_VSI_PORT_HEX}\" \"\${IDPF_VSI_PORT_DEC}\"  \"\${IDPF_NET_NAME}\" \"\${IDPF_NET_MAC}\" \"\${IDPF_NET_IP}\") ; \
        printf \"| %-10s | %-10s | %-10s | %-15s | %-15s |\\n\" \"0x\${IDPF_VSI_ID_HEX}(\${IDPF_VSI_ID_DEC})\" \"0x\${IDPF_VSI_PORT_HEX}(\${IDPF_VSI_PORT_DEC})\"  \"\${IDPF_NET_NAME}\" \"\${IDPF_NET_MAC}\" \"\${IDPF_NET_IP}\"  ; \
        idpf_array+=(\"\${arr[@]}\") ; \
    done'"