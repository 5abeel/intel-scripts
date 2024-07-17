#/bin/sh

#===========================================
# Port Representors Maps on Host and ACC
#===========================================

# devlink vport assignments from setup_infra.sh
IDPF_PF_VPORT=0 ; IDPF_COMMS_VPORT=3 ; IDPF_ARP_PROXY_VPORT=4

IDPF_VF_VPORT0=4 ;
idpf_ports=$(realpath /sys/class/net/*/dev_port | grep  $(lspci -nnkd 8086:1452 | awk  "NR==1{print \$1}") | sort)

printf "\n%-30s\n" '-HOST DEFAULT IDPF PORTS:-'
printf "%s\n" '-------------------------------------------------------------------------'
printf '| %-10s | %-10s | %-10s | %-15s | %-15s |\n' "VSI"  "PORT"  "  NETDEV"  "  MAC"  "  IP"
printf "%s\n" '-------------------------------------------------------------------------'

declare -a idpf_array=()
id=0
for port in ${idpf_ports} ; do
    netpath=$(dirname $port) ; \
        IDPF_NET_NAME=$(basename $netpath) ; \
        IDPF_NET_MAC=$(head $netpath/address) ; \
        IDPF_NET_IP=$(ifconfig ${IDPF_NET_NAME} | grep "inet " | awk "{print \$2}") ; \
        IDPF_VSI_ID_HEX=$(echo "${IDPF_NET_MAC}" | awk -F: "{print \$2}" | tr "[:lower:]" "[:upper:]") ; \
        IDPF_VSI_ID_DEC=$(echo "ibase=16; ${IDPF_VSI_ID_HEX}" | bc) ; \
        IDPF_VSI_PORT_DEC=$((IDPF_VSI_ID_DEC + 16)) ; \
        IDPF_VSI_PORT_HEX=$(echo "obase=16 ; ${IDPF_VSI_PORT_DEC}" | bc) ; \
        arr=("${IDPF_VSI_ID_HEX}" "${IDPF_VSI_ID_DEC}" "${IDPF_VSI_PORT_HEX}" "${IDPF_VSI_PORT_DEC}"  "${IDPF_NET_NAME}" "${IDPF_NET_MAC}" "${IDPF_NET_IP}") ; \
        printf "| %-10s | %-10s | %-10s | %-15s | %-15s |\n" "0x${IDPF_VSI_ID_HEX}(${IDPF_VSI_ID_DEC})" "0x${IDPF_VSI_PORT_HEX}(${IDPF_VSI_PORT_DEC})"  "${IDPF_NET_NAME}" "${IDPF_NET_MAC}" "${IDPF_NET_IP}"  ; \
        idpf_array+=("${arr[@]}") ; \
done

printf "\n%-30s\n" '-HOST SRIOV IDPF VF PORTS:-'
printf "%s\n" '-------------------------------------------------------------------------'
printf '| %-10s | %-10s | %-10s | %-15s | %-15s |\n' "VSI"  "PORT"  "  NETDEV"  "  MAC"  "  IP"
printf "%s\n" '-------------------------------------------------------------------------'

idpf_vf_ports=$(realpath /sys/class/net/*/dev_port | grep  $(lspci -nnkd 8086:145C | awk  "NR==1{print \$1}" | awk -F. "{print \$1}") | sort)
declare -a idpf_vf_array=()
id=0
for port in ${idpf_vf_ports} ; do
    netpath=$(dirname $port) ; \
        IDPF_NET_NAME=$(basename $netpath) ; \
        IDPF_NET_MAC=$(head $netpath/address) ; \
        IDPF_NET_IP=$(ifconfig ${IDPF_NET_NAME} | grep "inet " | awk "{print \$2}") ; \
        IDPF_VSI_ID_HEX=$(echo "${IDPF_NET_MAC}" | awk -F: "{print \$2}" | tr "[:lower:]" "[:upper:]") ; \
        IDPF_VSI_ID_DEC=$(echo "ibase=16; ${IDPF_VSI_ID_HEX}" | bc) ; \
        IDPF_VSI_PORT_DEC=$((IDPF_VSI_ID_DEC + 16)) ; \
        IDPF_VSI_PORT_HEX=$(echo "obase=16 ; ${IDPF_VSI_PORT_DEC}" | bc) ; \
        arr=("${IDPF_VSI_ID_HEX}" "${IDPF_VSI_ID_DEC}" "${IDPF_VSI_PORT_HEX}" "${IDPF_VSI_PORT_DEC}"  "${IDPF_NET_NAME}" "${IDPF_NET_MAC}" "${IDPF_NET_IP}") ; \
        printf "| %-10s | %-10s | %-10s | %-15s | %-15s |\n" "0x${IDPF_VSI_ID_HEX}(${IDPF_VSI_ID_DEC})" "0x${IDPF_VSI_PORT_HEX}(${IDPF_VSI_PORT_DEC})"  "${IDPF_NET_NAME}" "${IDPF_NET_MAC}" "${IDPF_NET_IP}"  ; \
        idpf_vf_array+=("${arr[@]}") ; \
done

printf "\n%-30s\n" '-ACC IDPF PORTS:-'
printf "%s\n" '-------------------------------------------------------------------------'
printf '| %-10s | %-10s | %-10s | %-15s | %-15s |\n' "VSI"  "PORT"  "  NETDEV"  "  MAC"  "  IP"
printf "%s\n" '-------------------------------------------------------------------------'

ACC_COMMS_IP=10.10.0.2
ssh -o LogLevel=quiet -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@${ACC_COMMS_IP} \
    'declare -a idpf_array=() ; \
    idpf_ports=$(realpath /sys/class/net/*/dev_port | grep  $(lspci -nnkd 8086:1452 | awk  "NR==1{print \$1}") | sort) ; \
    for port in ${idpf_ports} ; do \
        netpath=$(dirname $port) ; \
        IDPF_NET_NAME=$(basename $netpath) ; \
        IDPF_NET_MAC=$(head $netpath/address) ; \
        IDPF_NET_IP=$(ifconfig ${IDPF_NET_NAME} | grep "inet " | awk "{print \$2}") ; \
        IDPF_VSI_ID_HEX=$(echo "${IDPF_NET_MAC}" | awk -F: "{print \$2}" | tr "[:lower:]" "[:upper:]") ; \
        IDPF_VSI_ID_DEC=$(echo "ibase=16; ${IDPF_VSI_ID_HEX}" | bc) ; \
        IDPF_VSI_PORT_DEC=$((IDPF_VSI_ID_DEC + 16)) ; \
        IDPF_VSI_PORT_HEX=$(echo "obase=16 ; ${IDPF_VSI_PORT_DEC}" | bc) ; \
        arr=("${IDPF_VSI_ID_HEX}" "${IDPF_VSI_ID_DEC}" "${IDPF_VSI_PORT_HEX}" "${IDPF_VSI_PORT_DEC}"  "${IDPF_NET_NAME}" "${IDPF_NET_MAC}" "${IDPF_NET_IP}") ; \
        printf "| %-10s | %-10s | %-10s | %-15s | %-15s |\n" "0x${IDPF_VSI_ID_HEX}(${IDPF_VSI_ID_DEC})" "0x${IDPF_VSI_PORT_HEX}(${IDPF_VSI_PORT_DEC})"  "${IDPF_NET_NAME}" "${IDPF_NET_MAC}" "${IDPF_NET_IP}"  ; \
        idpf_array+=("${arr[@]}") ; \
    done'
