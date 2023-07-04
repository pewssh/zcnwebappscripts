#!/bin/bash

set -e

############################################################
# setup variables
############################################################

export PROJECT_ROOT=/root/codebase/zcnwebappscripts/test1 # /var/0chain

############################################################
# Checking Sharder counts.
############################################################
pushd ${PROJECT_ROOT} > /dev/null;
    #Sharder
    if [[ -f sharder/numsharder.txt ]] ; then
        echo "Checking for Sharders."
        SHARDER=$(cat sharder/numsharder.txt)
    fi

    #checking miner/shader var's
    if [[ -z ${SHARDER} ]] ; then
        exit 1
    fi
popd > /dev/null;

############################################################
# Extract sharder files
############################################################
pushd ${PROJECT_ROOT} > /dev/null;
    curl -L "https://github.com/0chain/zcnwebappscripts/raw/add/sharder-deploy1/artifacts/sharder-files.zip" -o /tmp/sharder-files.zip
    unzip -o /tmp/sharder-files.zip
    rm -rf /tmp/sharder-files.zip
    mv -rf sharder-files/* ${PROJECT_ROOT}/sharder/ssd/
    rm -rf /tmp/sharder-files*
popd > /dev/null;

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
# Executing sharder scripts
############################################################
pushd ${PROJECT_ROOT}/sharder/ssd > /dev/null;  #/sharder/ssd
    if [[ ${SHARDER} -gt 0 ]]; then
        bash docker.local/bin/init.setup.sh ${PROJECT_ROOT}/sharder/ssd ${PROJECT_ROOT}/sharder/hdd $SHARDER
    fi
popd > /dev/null;

############################################################
# Starting sharders
############################################################
pushd ${PROJECT_ROOT}/sharder/ssd/docker.local > /dev/null;  #/sharder/ssd
    for i in $(seq 1 $SHARDER)
    do
        cd sharder${i}
        bash ../bin/start.p0sharder.sh ${PROJECT_ROOT}/sharder/ssd ${PROJECT_ROOT}/sharder/hdd
        cd ../
    done
popd > /dev/null;
