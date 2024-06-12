#!/bin/bash

export BASE_DIR=/root/sabeel

###### SDE ###########

cleanup_sde() {
    rm -rf $BASE_DIR/p4-sde
    rm -rf $BASE_DIR/mev_cp
}

build_sde() {    
    mkdir p4-sde
    cd p4-sde
    mkdir install
    export SDE=$PWD
    export SDE_INSTALL=$SDE/install

    git clone https://github.com/intel-innersource/networking.ethernet.acceleration.vswitch.p4-sde.p4-driver.git -b main --recursive p4_sde-nat-p4-driver

    # mev_cp
    mkdir -p ~/.bin
    PATH="${HOME}/.bin:${PATH}"
    curl https://storage.googleapis.com/git-repo-downloads/repo > ~/.bin/repo
    chmod a+rx ~/.bin/repo

    mkdir $BASE_DIR/mev_cp
    cd $BASE_DIR/mev_cp
    repo init -u https://github.com/intel-innersource/networking.ipu.mountevans.manifests -b mev-ts-trunk -g SDE
    repo sync -j8
    ln -s  $BASE_DIR/mev_cp/sources/p4-cp/cp/  $SDE/p4_sde-nat-p4-driver/src/lld/mev/cp/nd_linux-mev_cp

    # Install deps
    cd $SDE/p4_sde-nat-p4-driver/tools/setup
    pip3 install distro
    python3 install_dep.py
    pip3 install meson pyelftools

    # SDE build
    cd $SDE/p4_sde-nat-p4-driver/tools/setup
    source p4sde_env_setup.sh $SDE

    cd $SDE/p4_sde-nat-p4-driver/
    ./autogen.sh
    ./configure --prefix=$SDE_INSTALL --enable-mev
    make -j24
    make install
}

###### stratum-deps ###########

cleanup_stratum_deps() {
    rm -rf $BASE_DIR/stratum-deps
}

build_stratum_deps() {
    cd $BASE_DIR
    git clone https://github.com/ipdk-io/stratum-deps.git
    cd stratum-deps
    cmake -B build -DCMAKE_INSTALL_PREFIX=./install
    cmake --build build -j8
}

###### networking-recipe ###########

cleanup_networking_recipe() {
    rm -rf $BASE_DIR/networking-recipe
}

build_networking_recipe() {

    export DEPEND_INSTALL=$BASE_DIR/stratum-deps/install

    # Set SDE env vars
    cd $BASE_DIR/p4-sde
    export SDE=$PWD
    cd p4_sde-nat-p4-driver/tools/setup
    source p4sde_env_setup.sh $SDE

    cd $BASE_DIR
    git clone https://github.com/ipdk-io/networking-recipe.git --recursive
    export P4CP_RECIPE=$BASE_DIR/networking-recipe

    # Install deps
    cd $P4CP_RECIPE
    yum install libatomic libnl3-devel
    pip3 install -r requirements.txt

    ./make-all.sh --target=es2k -D $DEPEND_INSTALL --rpath
}



# Check if an argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 [1|2|3|all]"
    echo "1 = SDE + mev_cp"
    echo "2 = stratum-deps"
    echo "3 = networking-recipe"
    echo "all = SDE; stratum-deps; networking-recipe"
    exit 1
fi

# Run the specified functions
case "$1" in
    1)
        cleanup_sde
        build_sde
        ;;
    2)
        cleanup_stratum_deps
        build_stratum_deps
        ;;
    3)
        cleanup_networking_recipe
        build_networking_recipe
        ;;
    all)
        cleanup_sde
        build_sde
        cleanup_stratum_deps
        build_stratum_deps
        cleanup_networking_recipe
        build_networking_recipe
        ;;
    *)
        echo "Invalid argument. Use 1, 2, 3, or all."
        exit 1
        ;;
esac
