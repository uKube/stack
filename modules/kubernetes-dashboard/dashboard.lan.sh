#!/bin/bash

DOMAIN=`basename -- "$0" .sh`

# Thanks to http://stackoverflow.com/a/10467453
function sedeasy {
  sed -i "s/$(echo $1 | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/$(echo $2 | sed -e 's/[\/&]/\\&/g')/g" $3
}

# Install helm dependency with configuration
# $1: channel ( stable/incubator/test)
# $2: app name
function helm_install_with_config {
  # Copy the template
  cp -f config.tpl.yaml config.yaml

  # Replace the host domain
  sedeasy "VPS_POD_DOMAIN" "$DOMAIN" config.yaml

  helm install --name "$2" \
    -f "config.yaml" \
    "$1/$2" &>/dev/null
}

helm_install_with_config "stable" "kubernetes-dashboard"
