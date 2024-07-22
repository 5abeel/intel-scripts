
export PATH=/opt/p4/p4-cp-nws/bin:/opt/p4/p4-cp-nws/sbin:$PATH
export SDE_INSTALL=/opt/p4/p4sde
export LD_LIBRARY_PATH=/opt/p4/p4-cp-nws/lib:/opt/p4/p4-cp-nws/lib64:$SDE_INSTALL/lib64:$SDE_INSTALL/lib:/usr/lib64:/usr/lib:/usr/local/lib64:/usr/local/lib

export P4CP_INSTALL=/opt/p4/p4-cp-nws
export OUTPUT_DIR=/usr/share/stratum/lnp

export P4RT_CTL_CMD="p4rt-ctl -g 10.10.0.2:9559"
alias p4rt-ctl='p4rt-ctl -g 10.10.0.2:9559 '