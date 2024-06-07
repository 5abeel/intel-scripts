#!/bin/bash

set +xe

BUILD_NUM=56934
MANIFEST_BRANCH=trunk
CI_OR_OD=od

ARTIFACTORY_URL="https://ubit-artifactory-or.intel.com/artifactory/list/mountevans_sw_bsp-or-local/builds/official/mev-ts-${MANIFEST_BRANCH}/${CI_OR_OD}/mev-ts-${MANIFEST_BRANCH}-${CI_OR_OD}-${BUILD_NUM}"
USERNAME="sabeelan"

# P4C
# Get latest successful build number from this page:
# https://cje-ir-prod01.devtools.intel.com/nex-ncng-ipu/job/MEV/job/builds/job/official/job/mev-ts-trunk-bitbake/

BUILD_NUM_FOR_P4C=1805
P4C_ARTIFACTORY_URL="https://ubit-artifactory-or.intel.com/artifactory/list/mountevans_sw_bsp-or-local/builds/official/mev-ts-trunk-bitbake/ci/mev-ts-trunk-bitbake-ci-1805/deploy/mev-hw-b0-5.15-ci-189-fedora37.tgz"



function cleanup() {
    rm -rf ./${BUILD_NUM} # remove directory
    mkdir -p ./${BUILD_NUM}

    # P4C
    P4C_DIRNAME=p4c-${BUILD_NUM_FOR_P4C}
    rm -rf ./${P4C_DIRNAME} # remove directory
    mkdir -p ./${P4C_DIRNAME}
}

function download() {
    wget --user=$USERNAME --ask-password $ARTIFACTORY_URL/deploy-sdk/oem_generic/intel-ipu-eval-ssd-image-ts.${MANIFEST_BRANCH}.${BUILD_NUM}.tar.gz
    wget --user=$USERNAME --ask-password $ARTIFACTORY_URL/deploy-sdk/oem_generic/intel-ipu-recovery-firmware-and-tools-ts.${MANIFEST_BRANCH}.${BUILD_NUM}.tar.gz
    wget --user=$USERNAME --ask-password $ARTIFACTORY_URL/deploy-sdk/oem_generic/intel-ipu-host-components-ts.${MANIFEST_BRANCH}.${BUILD_NUM}.tar.gz
    wget --user=$USERNAME --ask-password $ARTIFACTORY_URL/deploy-sdk/internal_only/hw-p4-programs.ts.${MANIFEST_BRANCH}.${BUILD_NUM}.tgz
    wget --user=$USERNAME --ask-password $P4C_ARTIFACTORY_URL
}

function unzip_images() {
    tar -xvzf intel-ipu-eval-ssd-image-ts.${MANIFEST_BRANCH}.${BUILD_NUM}.tar.gz
    tar -xvzf intel-ipu-recovery-firmware-and-tools-ts.${MANIFEST_BRANCH}.${BUILD_NUM}.tar.gz
    tar -xvzf intel-ipu-host-components-ts.${MANIFEST_BRANCH}.${BUILD_NUM}.tar.gz
    tar -xvzf hw-p4-programs.ts.${MANIFEST_BRANCH}.${BUILD_NUM}.tgz
    tar -xvzf mev-hw-b0-5.15-ci-189-fedora37.tgz
}

function upgrade_p4c() {
    rpm -e $(rpm -q p4c) # uninstall old p4c

    cd host/packages/x86_64/
    rpm -ivh p4c-3.0.70.*
}

cleanup
cd ./${BUILD_NUM}
download
unzip_images
#upgrade_p4c
cd -




