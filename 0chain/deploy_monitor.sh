#!/bin/bash

set -e

############################################################
# setup variables
############################################################

export PROJECT_ROOT=/root/codebase/zcnwebappscripts/test1 # /var/0chain
export BLOBBER_HOST=BLOBBER_HOST
export GF_ADMIN_USER=admin
export GF_ADMIN_PASSWORD=admin

############################################################
# Checking Sharder counts.
############################################################
pushd ${PROJECT_ROOT} > /dev/null;
    #Sharder
    if [[ -f sharder/numsharder.txt ]] ; then
        echo "Checking for Sharders."
        SHARDER=$(cat sharder/numsharder.txt)
    fi
    #Miner
    if [[ -f miner/numminer.txt ]] ; then
        echo "Checking for Sharders."
        MINER=$(cat miner/numminer.txt)
    fi
    #Checking shader var's
    if [[ -z ${SHARDER} && -z ${MINER} ]] ; then
        echo "No Sharder/Miner exist."
        exit 1
    fi
popd > /dev/null;

############################################################
# Extract sharder files
############################################################
pushd ${PROJECT_ROOT} > /dev/null;
    curl -L "https://github.com/0chain/zcnwebappscripts/raw/add/sharder-deploy2/0chain/artifacts/grafana-portainer.zip" -o /tmp/grafana-portainer.zip
    unzip -o /tmp/grafana-portainer.zip -d ${PROJECT_ROOT}
popd > /dev/null;
exit
############################################################
# Copy configs.
############################################################
pushd ${PROJECT_ROOT} > /dev/null;
    if [[ ${SHARDER} -gt 0 ]] ; then
        echo "Copying sharder keys & configs."
        cp -rf keys/b0s* sharder/ssd/docker.local/config    # sharder/ssd/docker.local/config
        # cp -rf nodes.yaml sharder/ssd/docker.local/config
        # cp -rf magicblock.json sharder/ssd/docker.local/config
    fi
popd > /dev/null;

############################################################
# Starting sharders
############################################################
pushd ${PROJECT_ROOT}/grafana-portainer > /dev/null;  #/sharder/ssd
    bash ./start.p0monitor.sh ${BLOBBER_HOST} ${GF_ADMIN_USER} ${GF_ADMIN_PASSWORD}
popd > /dev/null;
