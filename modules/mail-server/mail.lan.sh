#!/bin/bash

DOMAIN=`basename -- "$0" .sh`

# Pod configurations
HOST_IPv4=`ip -4 route get 255.255.255.255 | head -1 | cut -f6 -d' '`
POD_DATAPATH="/srv/mail"
POD_LOCALTIMEPATH="/etc/localtime"

# Prepare the Mail Server data folder
echo ">> Creating /srv/mail folder..."
mkdir -p /srv/mail &>/dev/null

# Thanks to http://stackoverflow.com/a/10467453
function sedeasy {
  sed -i "s/$(echo $1 | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/$(echo $2 | sed -e 's/[\/&]/\\&/g')/g" $3
}

# Wait until POD is Running
function wait_until_pod_is_running {
  # Wait until the docker is up and running
  echo -n ">> Waiting for '$1' to start..."
  while [ ! $(kubectl get pods --all-namespaces -l $2 -o jsonpath="{.items[0].status.phase}" &>/dev/null && echo $?) ]
  do
      echo -n "."
      sleep 0.5
  done
  echo "started!"
}

# Install helm dependency with configuration
# $1: channel ( stable/incubator/test)
# $2: app name
function helm_install_with_config {
  # Copy the template
  cp -f config.tpl.yaml config.yaml

  # Replace configurations
  sedeasy "VPS_POD_DOMAIN" "$DOMAIN" config.yaml
  sedeasy "VPS_POD_DATAPATH" "$POD_DATAPATH" config.yaml
  sedeasy "VPS_POD_LOCALTIMEPATH" "$POD_LOCALTIMEPATH" config.yaml
  sedeasy "HOST_IPv4" "$HOST_IPv4" config.yaml

  helm install --name "${DOMAIN/./-}" \
    -f "config.yaml" \
    "$1/$2" &>/dev/null
}

helm_install_with_config "ukube" "posteio"

wait_until_pod_is_running "${DOMAIN/./-}" "app=posteio"

# Print friendly done message
echo "-----------------------------------------------------"
echo "All right! Everything seems to be installed correctly. Have a nice day!"
echo ">> Admin URL: https://${DOMAIN}/admin/login"
echo ">> User URL: https://${DOMAIN}/"
echo "-----------------------------------------------------"