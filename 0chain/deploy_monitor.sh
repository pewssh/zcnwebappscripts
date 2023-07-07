#!/bin/bash

set -e

echo -e "\n\e[93m===============================================================================================================================================================================
                                                                                setup variables 
===============================================================================================================================================================================  \e[39m"
export PROJECT_ROOT=/root/test1 # /var/0chain
export HOST=mb-test.devnet-0chain.net
export BLOCK_WORKER_URL=dev.zus.network
echo -e "\e[32m Successfully Created \e[23m \e[0;37m"

mkdir -p $PROJECT_ROOT

echo -e "\n\e[93m===============================================================================================================================================================================
                                                                                Checking Sharder/Miner counts.
===============================================================================================================================================================================  \e[39m"
pushd ${PROJECT_ROOT} > /dev/null;
    #Sharder
    if [[ -f sharder/numsharder.txt ]] ; then
        echo "Checking for Sharders."
        SHARDER=$(cat sharder/numsharder.txt)
    fi
    #Miner
    if [[ -f miner/numminers.txt ]] ; then
        echo "Checking for miners."
        MINER=$(cat miner/numminers.txt)
    fi
    #Email
    echo "Checking for email."
    if [[ -f miner/email.txt ]] ; then
        EMAIL=$(cat miner/email.txt)
    fi
    if [[ -f sharder/email.txt ]] ; then
        EMAIL=$(cat sharder/email.txt)
    fi
    #Checking sharder var's
    if [[ -z ${SHARDER} && -z ${MINER} ]] ; then
        echo "No Sharder/Miner exist."
        exit 1
    fi
    echo -e "\e[32m Counts exists \e[23m \e[0;37m"
popd > /dev/null;

echo -e "\n\e[93m===============================================================================================================================================================================
                                                                                Extract monitoring files
===============================================================================================================================================================================  \e[39m"
pushd ${PROJECT_ROOT} > /dev/null;
    curl -L "https://github.com/0chain/zcnwebappscripts/raw/add/sharder-deploy1/0chain/artifacts/grafana-portainer.zip" -o /tmp/grafana-portainer.zip
    unzip -o /tmp/grafana-portainer.zip -d ${PROJECT_ROOT}
    rm /tmp/grafana-portainer.zip
popd > /dev/null;

echo -e "\n\e[93m===============================================================================================================================================================================
                                                                                Creating promtail configs.
===============================================================================================================================================================================  \e[39m"
pushd ${PROJECT_ROOT} > /dev/null;
# Promtail config for sharder
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
# Promtail config for miner
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
echo -e "\e[32m Successfully Created \e[23m \e[0;37m"
popd > /dev/null;

echo -e "\n\e[93m===============================================================================================================================================================================
                                                                                Creating caddy configs.
===============================================================================================================================================================================  \e[39m"
pushd ${PROJECT_ROOT} > /dev/null;
# Promtail config for sharder

### Caddyfile
echo "creating Caddyfile"
cat <<EOF >${PROJECT_ROOT}/grafana-portainer/caddy/Caddyfile
(cors) {
  @cors_preflight method OPTIONS
  @cors header Origin {args.0}

  handle @cors_preflight {
    header Access-Control-Allow-Origin "*"
    header Access-Control-Allow-Methods "GET, POST, PUT, PATCH, DELETE"
    header Access-Control-Allow-Headers "*"
    header Access-Control-Max-Age "3600"
    respond "" 204
  }

  handle @cors {
    header Access-Control-Allow-Origin "*"
    header Access-Control-Expose-Headers "Link"
  }
}

${HOST} {
  import cors https://${HOST}
  log {
    output file /var/log/access.log {
      roll_size 1gb
      roll_keep 5
      roll_keep_for 720h
    }
  }
  route {
    redir https://${BLOCK_WORKER_URL}
  }

EOF

for i in $(seq 1 ${SHARDER}); do
cat <<EOF >>${PROJECT_ROOT}/grafana-portainer/caddy/Caddyfile
  route /sharder0${i}* {
    uri strip_prefix /sharder0${i}
    reverse_proxy sharder-${i}:717${i}
  }

EOF
done

for i in $(seq 1 ${MINER}); do
cat <<EOF >>${PROJECT_ROOT}/grafana-portainer/caddy/Caddyfile
  route /miner0${i}* {
    uri strip_prefix /miner0${i}
    reverse_proxy miner-${i}:707${i}
  }

EOF
done

cat <<EOF >>${PROJECT_ROOT}/grafana-portainer/caddy/Caddyfile
  route /portainer* {
    uri strip_prefix /portainer
    header Access-Control-Allow-Methods "POST,PATCH,PUT,DELETE, GET, OPTIONS"
    header Access-Control-Allow-Headers "*"
    header Access-Control-Allow-Origin "*"
    header Cache-Control max-age=3600
    reverse_proxy portainer:9000
  }

  route /grafana* {
    uri strip_prefix /grafana
    reverse_proxy grafana:3000
  }
}
EOF

echo -e "\e[32m Successfully Created \e[23m \e[0;37m"
popd > /dev/null;

echo -e "\n\e[93m===============================================================================================================================================================================
                                                                                Generate random password for grafana and portainer
===============================================================================================================================================================================  \e[39m"
pushd ${PROJECT_ROOT}/grafana-portainer/portainer > /dev/null;
    if [[ -f portainer_password ]] ; then
      PASSWORD=$(cat portainer_password)
    else
      tr -dc A-Za-z0-9 </dev/urandom | head -c 13 > portainer_password
      PASSWORD=$(cat portainer_password)
    fi
echo -e "\e[32m Successfully Created \e[23m \e[0;37m"
popd > /dev/null;

echo -e "\n\e[93m===============================================================================================================================================================================
                                                                                Deploying grafana and portainer
===============================================================================================================================================================================  \e[39m"
pushd ${PROJECT_ROOT}/grafana-portainer > /dev/null;  #/sharder/ssd
    bash ./start.p0monitor.sh ${HOST} ${EMAIL} ${PASSWORD}
popd > /dev/null;

echo -e "\n\e[93m===============================================================================================================================================================================
                                                                                Grafana and Portainer credentials
===============================================================================================================================================================================  \e[39m"
echo "Grafana Username --> ${EMAIL}"
echo "Grafana Password --> ${PASSWORD}"
echo -e "\n Portainer Username --> admin"
echo "Portainer Password --> ${PASSWORD}"
