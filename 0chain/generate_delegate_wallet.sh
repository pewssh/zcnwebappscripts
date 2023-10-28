#!/bin/bash

set -e

############################################################
# setup variables
############################################################
export PROJECT_ROOT="/var/0chain" # /var/0chain
mkdir -p $PROJECT_ROOT

echo -e "\n\e[93m===============================================================================================================================================================================
                                                                Installing some pre-requisite tools on your server
===============================================================================================================================================================================  \e[39m"
echo -e "\e[32m 1. Apt update. \e[23m \e[0;37m"
sudo apt update
echo -e "\e[32m 2. Installing jq, zip, unzip. \e[23m \e[0;37m"
sudo apt install jq zip unzip -y
sudo add-apt-repository ppa:ubuntu-toolchain-r/test -y
echo -e "\e[32m 2. Installing build essentials and gcc. \e[23m \e[0;37m"
apt-get -y install build-essential nghttp2 libnghttp2-dev libssl-dev
sudo apt install gcc-11 g++-11

echo -e "\n\e[93m===============================================================================================================================================================================
                                                                Persisting inputs.
===============================================================================================================================================================================  \e[39m"
pushd ${PROJECT_ROOT} > /dev/null;

    #Delegate Wallet Input
    if [[ -f delegate_wallet.json ]] ; then
        CLIENTID=$( jq -r .client_id delegate_wallet.json )
    else
        echo "\e[32m Creating new delegate wallet. \e[23m \e[0;37m"
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
                mkdir bin
                sudo cp -rf zwallet-binary/* ${PROJECT_ROOT}/bin/
                sudo rm -rf zwallet-binary
                echo "block_worker: https://beta.zus.network/dns" > config.yaml
                echo "signature_scheme: bls0chain" >> config.yaml
                echo "min_submit: 50" >> config.yaml
                echo "min_confirmation: 50" >> config.yaml
                echo "confirmation_chain_length: 3" >> config.yaml
                echo "max_txn_query: 5" >> config.yaml
                echo "query_sleep_time: 5" >> config.yaml
            else
                echo "Didn't found any Ubuntu version with 20/22."
            fi
        fi
        ./bin/zwallet create-wallet --wallet delegate_wallet.json --configDir . --config config.yaml --silent
        CLIENTID=$( jq -r .client_id delegate_wallet.json )
    fi
popd > /dev/null;

echo -e "\n\e[93m===============================================================================================================================================================================
                                                                Ouput delegate wallet id.
===============================================================================================================================================================================  \e[39m"
pushd ${PROJECT_ROOT} > /dev/null;
    if [[ -z ${CLIENTID} ]]; then
        echo "Delegate wallet didn't got created. Please check with zus team"
        exit 1
    else
        echo "Delegate wallet ID: ${CLIENTID}"
        sudo sh -c "echo -n ${CLIENTID} > del_wal_id.txt"
    fi
popd > /dev/null;
