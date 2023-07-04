#!/bin/bash

set -e

############################################################
# setup variables
############################################################

export PROJECT_ROOT=/root/codebase/zcnwebappscripts # /var/0chain

############################################################
# Checking Miner/Sharder counts.
############################################################
pushd ${PROJECT_ROOT} > /dev/null;

    #Miner
    if [[ -f sharder/numsharder.txt ]] ; then
        echo "Checking for Miners."
        MINER=$(cat miner/numminers.txt)
    fi

    #Sharder
    if [[ -f sharder/numsharder.txt ]] ; then
        echo "Checking for Sharders."
        SHARDER=$(cat sharder/numsharder.txt)
    fi

    #checking miner/shader var's
    if [[ ! -z ${SHARDER} && ! -z ${MINER} ]] ; then
        exit 1
    fi
popd > /dev/null;

############################################################
# Copy configs.
############################################################
pushd ${PROJECT_ROOT} > /dev/null;
    if [[ ${SHARDER} -gt 0 ]] ; then
        echo "Copying sharder keys & configs."
        cp -rf keys/b0s* sharder-files/ssd/docker.local/config    # sharder/ssd/docker.local/config
        # cp -rf nodes.yaml sharder-files/ssd/docker.local/config
        # cp -rf magicblock.json sharder-files/ssd/docker.local/config
    fi
    if [[ ${MINER} -gt 0 ]] ; then
        echo "Copying miner keys & configs."
        cp -rf keys/b0m* miner-files/ssd/docker.local/config      # miner/ssd/docker.local/config
        cp -rf output/b0m* miner-files/ssd/docker.local/config
        # cp -rf nodes.yaml miner-files/ssd/docker.local/config
        # cp -rf magicblock.json miner-files/ssd/docker.local/config
    fi
popd > /dev/null;

############################################################
# Executing sharder scripts
############################################################
pushd ${PROJECT_ROOT}/sharder-files > /dev/null;  #/sharder/ssd
    if [[ ${SHARDER} -gt 0 ]]; then
        bash docker.local/bin/init.setup.sh ${PROJECT_ROOT}/sharder-files/ssd ${PROJECT_ROOT}/sharder-files/hdd $SHARDER
    fi
popd
