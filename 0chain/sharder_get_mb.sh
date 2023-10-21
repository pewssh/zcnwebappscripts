#!/bin/bash

set -e

echo -e "\n\e[93m===============================================================================================================================================================================
                                                                                    Setup variables
===============================================================================================================================================================================  \e[39m"

export PROJECT_ROOT="/var/0chain" # /var/0chain
export PROJECT_ROOT_SSD=/var/0chain/sharder/ssd # /var/0chain/sharder/ssd
export PROJECT_ROOT_HDD=/var/0chain/sharder/hdd # /var/0chain/sharder/ssd
echo -e "\e[32m Successfully Created \e[23m \e[0;37m"

echo -e "\n\e[93m===============================================================================================================================================================================
                                                                                Checking Sharder counts.
===============================================================================================================================================================================  \e[39m"
pushd ${PROJECT_ROOT} > /dev/null;
    #Sharder
    if [[ -f sharder/numsharder.txt ]] ; then
        SHARDER=$(cat sharder/numsharder.txt)
    else
        echo "Checking for Sharders."
    fi
    echo -e "\e[32m Successfully Checked \e[23m \e[0;37m"

popd > /dev/null;

echo -e "\n\e[93m===============================================================================================================================================================================
                                                                                Downloading Keygen Binary
===============================================================================================================================================================================  \e[39m"
pushd ${PROJECT_ROOT} > /dev/null;
    if [[ ${SHARDER} -gt 0 ]] ; then
        if [[ -f bin/keygen ]] ; then
            echo -e "\e[32m Keygen binary present \e[23m \e[0;37m"
        else
            wget https://github.com/0chain/onboarding-cli/releases/download/binary%2Fubuntu-18/keygen-linux.tar.gz
            tar -xvf keygen-linux.tar.gz
            rm keygen-linux.tar.gz*
            echo "server_url : https://mb-gen.0chain.net/" > server-config.yaml
        fi
    else
        echo "No sharder present."
        exit 1
    fi
popd > /dev/null;

echo -e "\n\e[93m===============================================================================================================================================================================
                                                                            Downloading magicblock for Sharder.
===============================================================================================================================================================================  \e[39m"
pushd ${PROJECT_ROOT} > /dev/null;
    if [[ ${SHARDER} -gt 0 ]]; then
        echo "Downloading magicblock"
        sudo ./bin/keygen get-magicblock
        sudo ./bin/keygen get-initialstates
    else
        echo "No sharder present"
    fi
popd

echo -e "\n\e[93m===============================================================================================================================================================================
                                                                                Disk setup
===============================================================================================================================================================================  \e[39m"
pushd ${PROJECT_ROOT} > /dev/null;
    # if [[ ! -d ${PROJECT_ROOT_HDD} || ! -d ${PROJECT_ROOT_SSD} ]]; then
        sudo mkdir -p disk-setup/
        sudo wget https://raw.githubusercontent.com/0chain/zcnwebappscripts/main/disk-setup/disk_setup.sh -O disk-setup/disk_setup.sh
        sudo wget https://raw.githubusercontent.com/0chain/zcnwebappscripts/main/disk-setup/disk_func.sh -O disk-setup/disk_func.sh

        sudo chmod +x disk-setup/disk_setup.sh
        bash disk-setup/disk_setup.sh $PROJECT_ROOT_SSD $PROJECT_ROOT_HDD
    # fi
    echo -e "\e[32m Successfully Created \e[23m \e[0;37m"
popd > /dev/null;