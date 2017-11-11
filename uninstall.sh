#!/bin/bash

# Purge the whole stack
kubeadm reset &>/dev/null

# Purge CNI binaries
rm -Rf /opt/cni

# Print friendly done message
echo "--------------------------------------------"
echo "Stack purged successfully. Have a nice day!"
echo "--------------------------------------------"
