#!/bin/bash

set +xe

CI_NUM=55915
CI_TYPE=trunk

ARTIFACTORY_URL="https://ubit-artifactory-or.intel.com/artifactory/list/mountevans_sw_bsp-or-local/builds/official/mev-ts-${CI_TYPE}/ci/mev-ts-${CI_TYPE}-ci-${CI_NUM}"
USERNAME="sabeelan"

function cleanup() {
    rm -rf ./${CI_NUM} #remove directory
    mkdir -p ./${CI_NUM}
}

function download() {
    wget --user=$USERNAME --ask-password $ARTIFACTORY_URL/deploy-sdk/oem_generic/intel-ipu-eval-ssd-image-ts.${CI_TYPE}.${CI_NUM}.tar.gz

    wget --user=$USERNAME --ask-password $ARTIFACTORY_URL/deploy-sdk/oem_generic/intel-ipu-recovery-firmware-and-tools-ts.${CI_TYPE}.${CI_NUM}.tar.gz
}

function unzip_images(){
    tar -xvzf intel-ipu-eval-ssd-image-ts.${CI_TYPE}.${CI_NUM}.tar.gz
    tar -xvzf intel-ipu-recovery-firmware-and-tools-ts.${CI_TYPE}.${CI_NUM}.tar.gz
}

cleanup
cd ./${CI_NUM}
download
unzip_images
cd -

