#!/bin/bash

set -e

############################################################
# setup variables
############################################################

export PROJECT_ROOT=/root/codebase/zcnwebappscripts/test1 # /var/0chain
export BLOBBER_HOST=BLOBBER_HOST
export GF_ADMIN_USER=admin
export GF_ADMIN_PASSWORD=admin

# rm -rf test1
mkdir -p $PROJECT_ROOT

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
    if [[ -f miner/numminers.txt ]] ; then
        echo "Checking for Sharders."
        MINER=$(cat miner/numminers.txt)
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

############################################################
# Copy configs.
############################################################
pushd ${PROJECT_ROOT} > /dev/null;
    for i in $(seq 1 $SHARDER); do
cat <<EOF >>${PROJECT_ROOT}/grafana-portainer/promtail/promtail-config.yaml
- job_name: sharder${i}
  static_configs:
    - targets:
        - localhost
      labels:
        app: sharder-${i}
        __path__: /var/log/sharder${i}/log/*log
EOF
    done
echo $MINER
    for j in $(seq 1 $MINER); do
cat <<EOF >>${PROJECT_ROOT}/grafana-portainer/promtail/promtail-config.yaml
- job_name: miner${j}
  static_configs:
    - targets:
        - localhost
      labels:
        app: miner-${j}
        __path__: /var/log/miner${j}/log/*log
EOF
    done
popd > /dev/null;
exit
############################################################
# Starting sharders
############################################################
pushd ${PROJECT_ROOT}/grafana-portainer > /dev/null;  #/sharder/ssd
    bash ./start.p0monitor.sh ${BLOBBER_HOST} ${GF_ADMIN_USER} ${GF_ADMIN_PASSWORD}
popd > /dev/null;
