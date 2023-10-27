#!/bin/bash

set -e

############################################################
# setup variables
############################################################
export PROJECT_ROOT="/var/0chain" # /var/0chain

echo -e "\n\e[93m===============================================================================================================================================================================
                                                                Installing some pre-requisite tools on your server
===============================================================================================================================================================================  \e[39m"
echo -e "\e[32m 1. Apt update. \e[23m \e[0;37m"
sudo apt update
echo -e "\e[32m 2. Installing jq, zip, unzip. \e[23m \e[0;37m"
sudo apt install jq zip unzip -y

echo -e "\n\e[93m===============================================================================================================================================================================
                                                                Persisting inputs.
===============================================================================================================================================================================  \e[39m"
pushd ${PROJECT_ROOT} > /dev/null;

    #Delegate Wallet Input
    if [[ -f delegate_wallet.json ]] ; then
        CLIENTID=$( jq -r .client_id delegate_wallet.json )
        echo "Delegate wallet already exists with ID ${CLIENTID}"
    else
        echo "Creating new delegate wallet."
        if [[ -f bin/zwallet ]] ; then
            echo "zwallet binary already present"
        else
            ubuntu_version=$(lsb_release -rs | cut -f1 -d'.')
            if [[ ${ubuntu_version} -eq 18 ]]; then
                echo "Ubuntu 18 is not supported"
                exit 1
            elif [[ ${ubuntu_version} -eq 20 || ${ubuntu_version} -eq 22 ]]; then
                curl -L "https://github.com/0chain/zcnwebappscripts/raw/as-deploy/0chain/artifacts/zwallet-binary.zip" -o /tmp/zwallet-binary.zip
                sudo unzip -o /tmp/zwallet-binary.zip && rm -rf /tmp/zwallet-binary.zip
                sudo cp -rf zwallet-binary/* ${PROJECT_ROOT}/bin
                sudo rm -rf zwallet-binary
            else
                echo "Didn't found any Ubuntu version with 20/22."
            fi
        fi
        ./bin/zwallet create-wallet --wallet delegate_wallet.json
    fi

popd > /dev/null;
