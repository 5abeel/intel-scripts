# Scripts to setup IPU pkgs

This script assumes ConfigL setup and the scripts in this repo to run on the LP.


But it will also work where IMC is directly accessibly from host on the 100.0.0.x network.
Simply replace Host IP in scripts to `localhost`.

## Steps to run in order

1. Upgrade CI image on the system under test (SUT)
2. Copy the artifacts to ./target_copy/<release.CI#>/fxp-net_linux-networking/fxp-net_linux-networking folder
3. Update `config.env` to suit your environment and IP addresses
4. Review `full-bringup` and run script

Alternative to #4, run each step independently
* Run `./1-setup-imc-acc.sh`
    - Removes old artifacts from ACC
    - Validates the CI number to check for compatibility
    - Copies fxp-net_linux-networking.pkg & load_custom_pkg.sh from ./target_copy to IMC and reboots IMC
    - Waits for IMC to come up and verifies the config for LNW
    - Waits for ACC to come up and copies fxp-net_linux-networking from ./target_copy to ACC
    - Calls 'sync_time' to synchronize time between IMC, ACC, Host and LP
    - Updates the /usr/share/stratum/es2k/es2k_skip_p4.conf file to update ACC's `enp0s1f0d4`, `enp0s1f0d5`, and `enp0s1f0d6` MAC addresses to be used as PRs
* Run `./2-init-acc.sh`
    - Stops running infrap4d/ovs processes on ACC, and stops IDPF on host
    - (Re-)generates certs (if not present or expired)
    - Starts infrap4d and waits for switchd to come up
    - Sets forwarding pipeline
    - Starts IDPF driver on host
    - Configures host interface for comms channel & copies certs to host
    - Prints all VF ports for review
* Run `./3-auto.sh` or `./3-auto-vxlan-ipsec-tunnel.sh` or run commands manually
    - Sets up the networking, programs P4 rules
    - Starts OVS
    - Configures the networking interfaces on the LP


