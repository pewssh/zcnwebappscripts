#!/bin/bash

set -e

echo -e "\n\e[93m===============================================================================================================================================================================
                                                                        setup variables
===============================================================================================================================================================================  \e[39m"
export PROJECT_ROOT=/root/test1 # /var/0chain
export PROJECT_ROOT_SSD=/var/0chain/miner/ssd # /var/0chain/miner/ssd
export PROJECT_ROOT_HDD=/var/0chain/miner/hdd # /var/0chain//miner/ssd
echo -e "\e[32m Successfully Created \e[23m \e[0;37m"

echo -e "\n\e[93m===============================================================================================================================================================================
                                                                        Checking Miner counts.
===============================================================================================================================================================================  \e[39m"
pushd ${PROJECT_ROOT} > /dev/null;

    #miner
    if [[ -f miner/numminers.txt ]] ; then
        echo -e "\e[32m Sharder's count present \e[23m \e[0;37m"
        MINER=$(cat miner/numminers.txt)
    fi

    #checking miner var's
    if [[ -z ${MINER} ]] ; then
        echo -e "\e[32m Miner's not present \e[23m \e[0;37m"
        exit 1
    fi
popd > /dev/null;

echo -e "\n\e[93m===============================================================================================================================================================================
                                                                        Disk setup
===============================================================================================================================================================================  \e[39m"
pushd ${PROJECT_ROOT} > /dev/null;
    mkdir -p disk-setup/
    wget https://raw.githubusercontent.com/0chain/zcnwebappscripts/main/disk-setup/disk_setup.sh -O disk-setup/disk_setup.sh
    wget https://raw.githubusercontent.com/0chain/zcnwebappscripts/main/disk-setup/disk_func.sh -O disk-setup/disk_func.sh

    sudo chmod +x disk-setup/disk_setup.sh
    # bash disk-setup/disk_setup.sh $PROJECT_ROOT_SSD $PROJECT_ROOT_HDD
popd > /dev/null;

echo -e "\n\e[93m===============================================================================================================================================================================
                                                                        Extract miner files
===============================================================================================================================================================================  \e[39m"
pushd ${PROJECT_ROOT} > /dev/null;
    curl -L "https://github.com/0chain/zcnwebappscripts/raw/add/sharder-deploy1/0chain/artifacts/miner-files.zip" -o /tmp/miner-files.zip
    unzip -o /tmp/miner-files.zip && rm -rf /tmp/miner-files.zip
    cp -rf miner-files/* ${PROJECT_ROOT}/miner/ssd/
    rm -rf miner-files
popd > /dev/null;

echo -e "\n\e[93m===============================================================================================================================================================================
                                                                        Copying configs.
===============================================================================================================================================================================  \e[39m"
pushd ${PROJECT_ROOT} > /dev/null;
    if [[ ${MINER} -gt 0 ]] ; then
        echo "Copying miner keys & configs."
        cp -rf keys/b0m* miner/ssd/docker.local/config      # miner/ssd/docker.local/config
        cp -rf output/b0m* miner/ssd/docker.local/config
        cp -rf dkgSummary-* miner/ssd/docker.local/config
        cat nodes.yaml > miner/ssd/docker.local/config/nodes.yaml
        cat b0magicBlock.json > miner/ssd/docker.local/config/b0magicBlock_4_miners_2_sharders.json
        cat initial_states.yaml > miner/ssd/docker.local/config/initial_state.yaml
    fi
popd > /dev/null;

echo -e "\n\e[93m===============================================================================================================================================================================
                                                                        Executing miner scripts
===============================================================================================================================================================================  \e[39m"
pushd ${PROJECT_ROOT}/miner/ssd > /dev/null;  #/miner/ssd
    if [[ ${MINER} -gt 0 ]]; then
        bash docker.local/bin/init.setup.sh ${PROJECT_ROOT}/miner/ssd ${PROJECT_ROOT}/miner/hdd $MINER
        bash docker.local/bin/setup.network.sh || true
    fi
popd > /dev/null;

echo -e "\n\e[93m===============================================================================================================================================================================
                                                                        Starting miners
===============================================================================================================================================================================  \e[39m"
pushd ${PROJECT_ROOT}/miner/ssd/docker.local > /dev/null;  #/miner/ssd
    for i in $(seq 1 $MINER)
    do
        cd miner${i}
        bash ../bin/start.p0miner.sh ${PROJECT_ROOT}/miner/ssd ${PROJECT_ROOT}/miner/hdd
        cd ../
    done
popd > /dev/null;
