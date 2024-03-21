#!/bin/bash

export TAG=v1.13.0
export PROJECT_ROOT=/var/0chain/blobber

sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 || true
sudo chmod a+x /usr/local/bin/yq || true

yq e -i ".services.validator.image = \"0chaindev/validator:${TAG}\"" ${PROJECT_ROOT}/docker-compose.yml
yq e -i ".services.blobber.image = \"0chaindev/blobber:${TAG}\"" ${PROJECT_ROOT}/docker-compose.yml
/usr/local/bin/docker-compose -f ${PROJECT_ROOT}/docker-compose.yml pull
/usr/local/bin/docker-compose -f ${PROJECT_ROOT}/docker-compose.yml up -d
