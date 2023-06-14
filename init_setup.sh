#!/bin/bash

set -e

############################################################
# setup variables
############################################################
export MINER=1
export SHARDER=0
export PROJECT_ROOT=/root/codebase/zcnwebappscripts

rm -rf miner
rm -rf sharder

if [[ ${MINER} -gt 0 ]] ; then
    mkdir -p ${PROJECT_ROOT}/miner
fi

if [[ ${SHARDER} -gt 0 ]] ; then
    mkdir -p ${PROJECT_ROOT}/sharder
fi

# cd ~
# mkdir -p ${PROJECT_ROOT}

############################################################
# Persisting Miner/Sharder inputs.
############################################################
pushd ${PROJECT_ROOT} > /dev/null;

    #DNS Input
    if [[ -f miner/url.txt && ${MINER} -gt 0 ]] ; then
        PUBLIC_ENDPOINT=$(cat miner/url.txt)
    fi
    if [[ -f sharder/url.txt && ${SHARDER} -gt 0 ]] ; then
        PUBLIC_ENDPOINT=$(cat sharder/url.txt)
    fi
    while [[ -z ${PUBLIC_ENDPOINT} ]]
    do
        read -p "Enter the PUBLIC_URL or your domain name. Example: john.mydomain.com : " PUBLIC_ENDPOINT
    done

    #Email Input
    if [[ -f miner/email.txt && ${MINER} -gt 0 ]] ; then
        EMAIL=$(cat miner/email.txt)
    fi
    if [[ -f sharder/email.txt && ${SHARDER} -gt 0 ]] ; then
        EMAIL=$(cat sharder/email.txt)
    fi
    while [[ -z ${EMAIL} ]]
    do
        read -p "Enter the EMAIL: " EMAIL
    done

    #Miner
    if [[ ${MINER} -gt 0 ]] ; then
        if [[ -f sharder/numsharder.txt ]] ; then
            MINER=$(cat miner/numminers.txt)
        else
            echo -n ${MINER} > miner/numminers.txt
            echo -n ${PUBLIC_ENDPOINT} > miner/url.txt
            echo -n ${EMAIL} > miner/email.txt
        fi
    fi

    #Sharder
    if [[ ${SHARDER} -gt 0 ]] ; then
        if [[ -f sharder/numsharder.txt ]] ; then
            SHARDER=$(cat sharder/numsharder.txt)
        else
            echo -n ${SHARDER} > sharder/numsharder.txt
            echo -n ${PUBLIC_ENDPOINT} > sharder/url.txt
            echo -n ${EMAIL} > sharder/email.txt
        fi
    fi

popd > /dev/null;

pushd
    ############################################################
    # Downloading Keygen Binary
    ############################################################
    if [[ -f bin/keygen ]] ; then
        echo "Keygen binary already present"
    else
        wget https://github.com/0chain/onboarding-cli/releases/download/main/keygen-linux.tar.gz
        tar -xvf keygen-linux.tar.gz
        rm keygen-linux.tar.gz*
    fi
popd

# pushd ${PROJECT_ROOT}
# cat <<\EOF >config.yaml
# miners:
#   - n2n_ip: $PUBLIC_ENDPOINT
#     public_ip: $PUBLIC_ENDPOINT
#     port: 7071
#     description:$EMAIL
# EOF
# popd





exit


sudo apt install parted build-essential dnsutils git nano jq htop zip unzip -y

DOCKERCOMPOSEVER=v2.2.3 ; sudo apt install docker.io -y ; sudo systemctl enable --now docker ; docker --version	 ; sudo curl -L "https://github.com/docker/compose/releases/download/$DOCKERCOMPOSEVER/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose ; sudo chmod +x /usr/local/bin/docker-compose ; docker-compose --version

sudo chmod 777 /var/run/docker.sock

if [[ ! -d z ]]
then
	apt install zip unzip -y
#	wget https://zcdn.uk/wp-content/uploads/2022/11/zdeployment-docker-deploy.zip
#	unzip zdeployment-docker-deploy.zip
#	rm zdeployment-docker-deploy.zip
#	mv zdeployment-docker-deploy z
fi

wget https://raw.githubusercontent.com/0chain/asdeploy/main/config.sh -O config.sh
wget https://raw.githubusercontent.com/0chain/asdeploy/main/keygen.sh -O keygen.sh
wget https://raw.githubusercontent.com/0chain/asdeploy/main/fetchkeys.sh -O fetchkeys.sh
wget https://raw.githubusercontent.com/0chain/asdeploy/main/sharekeys.sh -O sharekeys.sh
wget https://raw.githubusercontent.com/0chain/asdeploy/main/minerdeploy.sh -O minerdeploy.sh
wget https://raw.githubusercontent.com/0chain/asdeploy/main/sharderdeploy.sh -O sharderdeploy.sh
wget https://raw.githubusercontent.com/0chain/asdeploy/main/nginx.sh -O nginx.sh
wget https://raw.githubusercontent.com/0chain/asdeploy/main/blobberconfig.sh -O blobberconfig.sh
wget https://raw.githubusercontent.com/0chain/asdeploy/main/blobgen.sh -O blobgen.sh
wget https://raw.githubusercontent.com/0chain/asdeploy/main/blobinit.sh -O blobinit.sh
wget https://raw.githubusercontent.com/0chain/asdeploy/main/blobrun.sh -O blobrun.sh
wget https://raw.githubusercontent.com/0chain/asdeploy/main/blobdel.sh -O blobdel.sh

URL=$(cat ${PROJECT_ROOT}/url.txt)
ipaddr=$(curl api.ipify.org)
myip=$(dig +short $URL)
if [[ "$myip" != "$ipaddr" ]]
then
  echo "$URL IP resolution mistmatch $myip vs $ipaddr"
else
  echo "SUCCESS $URL resolves to $myip"
fi

