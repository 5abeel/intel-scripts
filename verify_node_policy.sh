#!/bin/bash

# Source the environment file
source ./config.env

# Verify values in host config
printf "Verifying node config on IMC..."

if [ "$PKG_NAME" = "fxp-net_linux-networking" ]; then
    ssh $SSH_OPTIONS $IMC "
        [ -L /etc/dpcp/package/default_pkg.pkg ] && [ \$(readlink /etc/dpcp/package/default_pkg.pkg) = '/etc/dpcp/package/fxp-net_linux-networking.pkg' ] &&
        grep -q 'sem_num_pages = 28' /etc/dpcp/cfg/default_cp_init.cfg &&
        grep -q 'lem_num_pages = 32' /etc/dpcp/cfg/default_cp_init.cfg &&
        grep -q 'mod_num_pages = 2' /etc/dpcp/cfg/default_cp_init.cfg &&
        grep -q 'cxp_num_pages = 5' /etc/dpcp/cfg/default_cp_init.cfg &&
        grep -q 'acc_apf = 16' /etc/dpcp/cfg/default_cp_init.cfg &&
        grep -q 'cpf_host = 4' /etc/dpcp/cfg/default_cp_init.cfg &&
        grep -qP 'comm_vports\\s*=\\s*\\(\\(\\[5,0\\],\\[4,0\\]\\),\\(\\[0,3\\],\\[4,3\\]\\)\\)' /etc/dpcp/cfg/default_cp_init.cfg
    "
    if [ $? -eq 0 ]; then
        echo "Verified for Linux Networking!"
        exit 0
    else
        echo "Error: Node config required values not found in IMC for LNW."
        exit 1
    fi
elif [ "$PKG_NAME" = "fxp_connection-tracking" ]; then
    ssh $SSH_OPTIONS $IMC "
        [ -L /etc/dpcp/package/default_pkg.pkg ] && [ \$(readlink /etc/dpcp/package/default_pkg.pkg) = '/etc/dpcp/package/fxp_connection-tracking.pkg' ] &&
        grep -q 'lem_aging_num_pages = 3' /etc/dpcp/cfg/default_cp_init.cfg &&
        grep -qP 'comm_vports\\s*=\\s*\\(\\(\\[5,0\\],\\[4,0\\]\\),\\(\\[0,3\\],\\[4,3\\]\\)\\)' /etc/dpcp/cfg/default_cp_init.cfg
    "
    if [ $? -eq 0 ]; then
        echo "Verified for Connection Tracking!"
        exit 0
    else
        echo "Error: Node config required values not found in IMC for CT."
        exit 1
    fi
else
    echo "Error: Unknown PKG_NAME: $PKG_NAME"
    exit 1
fi
