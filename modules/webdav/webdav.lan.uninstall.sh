#!/bin/bash

DOMAIN=`basename -- "$0" .uninstall.sh`
MODULE=${DOMAIN/./-}

if [ ! -z `helm list --deployed --short $MODULE` ]; then
  # Purge the whole deployment
  helm del --purge \
    $MODULE &>/dev/null

  # Print friendly done message
  echo "--------------------------------------------"
  echo "Module purged successfully. Have a nice day!"
  echo "--------------------------------------------"
else
  # Print friendly done message
  echo "---------------------------------------------"
  echo "Module not found. Are you sure it is deployed?"
  echo "---------------------------------------------"
fi