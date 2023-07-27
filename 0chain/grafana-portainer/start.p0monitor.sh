#!/bin/sh
set -e

HOST=$1
EMAIL=$2
PASSWORD=$3

# echo $PROJECT_ROOT

echo Deploying monitoring essentials in daemon mode ...

HOST=${HOST} GF_ADMIN_USER=${EMAIL} GF_ADMIN_PASSWORD=${PASSWORD} docker-compose -f docker-compose.yaml up -d
