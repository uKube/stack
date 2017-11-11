#!/bin/bash

# Purge the whole stack
kubeadm reset &>/dev/null

# Print friendly done message
echo "--------------------------------------------"
echo "Stack purged successfully. Have a nice day!"
echo "--------------------------------------------"
