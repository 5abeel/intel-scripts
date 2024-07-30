# Scripts to setup LNWv3

This script assumes ConfigL setup and the scripts in this repo to run on the LP.


But it will also work where IMC is directly accessibly from host on the 100.0.0.x network.
Simply replace Host IP in scripts to `localhost`.

## Steps to run in order

1. Upgrade CI image on system under test (SUT) -- the script upgrade-ci.sh is still work-in-progress and does not work yet.
2. Copy the LNW artifacts to ./target_copy/lnp folder
3. Update `config.env` to suit your environment and IP addresses
4. Review `full-bringup` and run script

Alternative to #4, run each step independently
4a. Run `./1-setup-imc-acc.sh`
4b. Run `./2-init-acc.sh`
4c. Run `./3-auto.sh` or `./3-auto-vxlan-ipsec-tunnel.sh` or run manual entry commands 


