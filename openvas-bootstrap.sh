#!/bin/bash

git clone https://github.com/admirito/gvm-containers.git
apt update
apt install docker-compose -y
cd "/var/lib/waagent/custom-script/download/0/gvm-containers/"
( docker-compose -f /var/lib/waagent/custom-script/download/0/gvm-containers/nvt-sync.yml up &&
docker-compose -f /var/lib/waagent/custom-script/download/0/gvm-containers/cert-sync.yml up &&
docker-compose -f /var/lib/waagent/custom-script/download/0/gvm-containers/scap-sync.yml up &&
docker-compose -f /var/lib/waagent/custom-script/download/0/gvm-containers/gvmd-data-sync.yml up &&
docker-compose up ) &