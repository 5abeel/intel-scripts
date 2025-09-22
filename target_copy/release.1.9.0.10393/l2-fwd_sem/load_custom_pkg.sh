#!/bin/sh
CP_INIT_CFG=/etc/dpcp/cfg/cp_init.cfg
echo "Checking for custom package..."
if [ -e l2-fwd_sem.pkg ]; then
    echo "Custom package l2-fwd_sem.pkg found. Overriding default package"
    cp  l2-fwd_sem.pkg /etc/dpcp/package/
    rm -rf /etc/dpcp/package/default_pkg.pkg
    ln -s /etc/dpcp/package/l2-fwd_sem.pkg /etc/dpcp/package/default_pkg.pkg
    sed -i 's/acc_apf = 4;/acc_apf = 16;/g' $CP_INIT_CFG
    sed -i 's/comm_vports = .*/comm_vports = (([5,0],[4,0]),([0,3],[4,3]));/g' $CP_INIT_CFG
else
    echo "No custom package found. Continuing with default package"
fi

