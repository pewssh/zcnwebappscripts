#!/bin/bash

set -e

############################################################
# setup variables
############################################################

export PROJECT_ROOT=/root/codebase/zcnwebappscripts/test1 # /var/0chain

############################################################
# Checking Miner counts.
############################################################
pushd ${PROJECT_ROOT} > /dev/null;

    #miner
    if [[ -f miner/numminers.txt ]] ; then
        echo "Checking for Miners."
        MINER=$(cat miner/numminers.txt)
    fi

    #checking miner var's
    if [[ -z ${MINER} ]] ; then
        exit 1
    fi
popd > /dev/null;

############################################################
# Extract miner files
############################################################
cp -rf miner-files/* ${PROJECT_ROOT}/miner/ssd/

############################################################
# Copy configs.
############################################################
pushd ${PROJECT_ROOT} > /dev/null;
    if [[ ${MINER} -gt 0 ]] ; then
        echo "Copying miner keys & configs."
        cp -rf keys/b0m* miner/ssd/docker.local/config      # miner/ssd/docker.local/config
        cp -rf output/b0m* miner/ssd/docker.local/config
        # cp -rf nodes.yaml miner/ssd/docker.local/config
        # cp -rf magicblock.json miner/ssd/docker.local/config
    fi
popd > /dev/null;

############################################################
# Executing miner scripts
############################################################
pushd ${PROJECT_ROOT}/miner/ssd > /dev/null;  #/miner/ssd
    if [[ ${MINER} -gt 0 ]]; then
        bash docker.local/bin/init.setup.sh ${PROJECT_ROOT}/miner/ssd ${PROJECT_ROOT}/miner/hdd $MINER
    fi
popd > /dev/null;

############################################################
# Starting miners
############################################################
pushd ${PROJECT_ROOT}/miner/ssd/docker.local > /dev/null;  #/miner/ssd
    for i in $(seq 1 $MINER)
    do
        cd miner${i}
        # pwd
        bash ../bin/start.p0miner.sh ${PROJECT_ROOT}/miner/ssd ${PROJECT_ROOT}/miner/hdd
        cd ../
    done
popd > /dev/null;
