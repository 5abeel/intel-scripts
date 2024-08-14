# Scripts to setup LNWv3

This script assumes ConfigL setup and the scripts in this repo to run on the LP.


But it will also work where IMC is directly accessibly from host on the 100.0.0.x network.
Simply replace Host IP in scripts to `localhost`.

## Steps to run in order

1. Upgrade CI image on system under test (SUT)
2. Copy the LNW artifacts to ./target_copy/fxp-net_linux-networking folder
3. Update `config.env` to suit your environment and IP addresses
4. Review `full-bringup` and run script

Alternative to #4, run each step independently
* Run `./1-setup-imc-acc.sh`
    - Removes old artifacts from ACC
    - Copies fxp-net_linux-networking.pkg & load_custom_pkg.sh from ./target_copy to IMC and reboots IMC
    - Waits for IMC to come up and verifies the config for LNW
    - Waits for ACC to come up and copies fxp-net_linux-networking from ./target_copy to ACC
    - Calls 'sync_time' to synchronize time between all systems
* Run `./2-init-acc.sh`
    - Stops running infrap4d/ovs processes on ACC, and stops IDPF on host
    - Generates certs (if not present)
    - Starts infrap4d and waits for switchd to come up
    - Sets forwarding pipeline
    - Starts IDPF driver on host
    - Configures host interface for comms channel & copies certs to host
    - Prints all VF ports for review
* Run `./3-auto.sh` or `./3-auto-vxlan-ipsec-tunnel.sh` or run commands manually
    - Sets up the networking, programs P4 rules
    - Starts OVS
    - Configures the networking interfaces on the LP


