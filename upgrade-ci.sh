#!/bin/bash

BASE_DIR=/root/sabeel
BUILD_NUM=58888
MANIFEST_BRANCH=trunk
CI_OR_OD=ci

ARTIFACTORY_URL="https://ubit-artifactory-or.intel.com/artifactory/list/mountevans_sw_bsp-or-local/builds/official/mev-ts-${MANIFEST_BRANCH}/${CI_OR_OD}/mev-ts-${MANIFEST_BRANCH}-${CI_OR_OD}-${BUILD_NUM}"
USERNAME="sabeelan"

function cleanup() {
    rm -rf ${BASE_DIR}/${BUILD_NUM} # remove directory
    mkdir -p ${BASE_DIR}/${BUILD_NUM}
}

function download() {
    wget --user=$USERNAME --ask-password $ARTIFACTORY_URL/deploy-sdk/oem_generic/intel-ipu-eval-ssd-image-ts.${MANIFEST_BRANCH}.${BUILD_NUM}.tar.gz
    wget --user=$USERNAME --ask-password $ARTIFACTORY_URL/deploy-sdk/internal_only/hw-flash-internal.ts.${MANIFEST_BRANCH}.${BUILD_NUM}.tgz
}

function unzip_images() {
    tar -xvzf intel-ipu-eval-ssd-image-ts.${MANIFEST_BRANCH}.${BUILD_NUM}.tar.gz
    tar -xvzf hw-flash-internal.ts.${MANIFEST_BRANCH}.${BUILD_NUM}.tgz
}


# Function to run commands on remote host
function run_remote_commands() {
    echo "Running commands on IMC..."
    REMOTE_HOST="root@100.0.0.100"
    
    # List of commands to run on remote host
    COMMANDS=(
        umount -l /dev/loop0
        umount -l /dev/nvme0n1p*
        killall -9 tgtd
        dd if=/dev/zero of=/dev/nvme0n1 bs=64k status=progress
    )

    for cmd in "${COMMANDS[@]}"; do
        ssh "$REMOTE_HOST" "$cmd"
    done
}


function flash_image() {
    dd bs=16M if=${BASE_DIR}/${BUILD_NUM}/intel-ipu-eval-ssd-image-ts.${MANIFEST_BRANCH}.${BUILD_NUM}/SSD/ssd-image-mev.bin | ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@100.0.0.100 "dd bs=16M of=/dev/nvme0n1" status=progress
    ssh -o "UserKnownHostsFile=/dev/null" root@100.0.0.100 "flash_erase /dev/mtd0 0 0"
    dd bs=16M if=${BASE_DIR}/${BUILD_NUM}/anvm_images/image_256M/clara_peak_48g_micron_0xc17/50008/50008.bin  | ssh -o "UserKnownHostsFile=/dev/null" root@100.0.0.100 "dd bs=16M of=/dev/mtd0 status=progress"

}



# Main execution
main() {
    echo "Select which functions to run:"
    echo "1: Download and untar artifacts"
    echo "2: Run remote commands"
    echo "3: Flash images"
    echo "a: All of the above"
    read -p "Enter your choice (1/2/3/a): " choice

    case $choice in
        1)
            cleanup
            cd ${BASE_DIR}/${BUILD_NUM}
            download
            unzip_images
            ;;
        2)
            run_remote_commands
            ;;
        3)
            flash_image
            ;;
        a)
            cleanup
            cd ${BASE_DIR}/${BUILD_NUM}
            download
            unzip_images
            run_remote_commands
            flash_image
            ;;
        *)
            echo "Invalid choice. Exiting."
            exit 1
            ;;
    esac
}

# Run the main function
main



