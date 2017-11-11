#!/bin/bash

# Purge the whole stack
kubeadm reset &>/dev/null

# Purge CNI binaries
rm -Rf /opt/cni

# Purge Kubernetes configurations
rm -Rf /etc/kubernetes

# Purge Kubernetes local files
rm -Rf $HOME/.kube

# Purge Helm local files
rm -Rf $HOME/.helm

# Disable the Kubelet service
systemctl disable kubelet.service &>/dev/null
systemctl stop kubelet.service &>/dev/null

# Remove leftover files
rm -f /etc/systemd/system/kubelet.service.d/99-local-extras.conf

# Reload systemd
systemctl daemon-reload &>/dev/null

# Print friendly done message
echo "-------------------------------------------------------------"
echo "Stack purged successfully. It is suggested to reboot your VPS"
echo "if you intend to reinstall again this stack. Have a nice day!"
echo "-------------------------------------------------------------"
