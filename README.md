# Scripts to setup LNWv3

This script assumes ConfigL setup and the scripts in this repo to run on the LP.


But it will also work where IMC is directly accessibly from host on the 100.0.0.x network.
Simply replace Host IP in scripts to `localhost`.

## Steps to run in order

1. Upgrade CI image on system under test (SUT) -- the script upgrade-ci.sh is still work-in-progress and does not work yet.
2. Copy the LNW artifacts to ./target_copy/lnp folder
3. Update `config.env` to suit your environment and IP addresses
4. Run `./1-setup-imc-acc.sh`
5. Run `./2-init-acc.sh`
6. Networking setup in 3-manual.sh is not currently automated and work-in-progress. Run these manually in an ACC terminal


