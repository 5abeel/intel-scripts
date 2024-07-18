#!/bin/sh
CP_INIT_CFG=/etc/dpcp/cfg/cp_init.cfg
echo "Checking for custom package..."
if [ -e fxp-net_linux-networking.pkg ]; then
    echo "Custom package fxp-net_linux-networking.pkg found. Overriding default package"
    cp  fxp-net_linux-networking.pkg /etc/dpcp/package/
    rm -rf /etc/dpcp/package/default_pkg.pkg
    ln -s /etc/dpcp/package/fxp-net_linux-networking.pkg /etc/dpcp/package/default_pkg.pkg
   sed -i 's/sem_num_pages = .*;/sem_num_pages = 28;/g' $CP_INIT_CFG
   sed -i 's/lem_num_pages = .*;/lem_num_pages = 10;/g' $CP_INIT_CFG
   sed -i 's/mod_num_pages = .*;/mod_num_pages = 2;/g' $CP_INIT_CFG
   sed -i 's/acc_apf = 4;/acc_apf = 16;/g' $CP_INIT_CFG
   sed -i 's/cpf_host = .*;/cpf_host = 0;/g' $CP_INIT_CFG
   sed -i 's/comm_vports = .*/comm_vports = (([5,0],[4,0]),([0,3],[4,3]));/g' $CP_INIT_CFG
else
    echo "No custom package found. Continuing with default package"
fi

