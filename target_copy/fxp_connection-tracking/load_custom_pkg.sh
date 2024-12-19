#!/bin/sh
CP_INIT_CFG=/etc/dpcp/cfg/cp_init.cfg
echo "Checking for custom package..."
if [ -e fxp_connection-tracking.pkg ]; then
    echo "Custom package fxp_connection-tracking.pkg found. Overriding default package"
    cp  fxp_connection-tracking.pkg /etc/dpcp/package/
    rm -rf /etc/dpcp/package/default_pkg.pkg
    ln -s /etc/dpcp/package/fxp_connection-tracking.pkg /etc/dpcp/package/default_pkg.pkg
   sed -i 's/lem_aging_num_pages = .*;/lem_aging_num_pages = 3;/g' $CP_INIT_CFG
   sed -i 's/comm_vports = .*/comm_vports = (([5,0],[4,0]),([0,3],[4,3]));/g' $CP_INIT_CFG
else
    echo "No custom package found. Continuing with default package"
fi

