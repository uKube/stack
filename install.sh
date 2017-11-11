#!/bin/bash

HOST_IPv4=`ip -4 route get 255.255.255.255 | head -1 | cut -f6 -d' '`
HOST_IPv6=`ip -6 route get ::255.255.255.255 | head -1 | cut -f9 -d' '`

# Thanks to http://stackoverflow.com/a/10467453
function sedeasy {
  sed -i "s/$(echo $1 | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/$(echo $2 | sed -e 's/[\/&]/\\&/g')/g" $3
}

# Install helm dependency with configuration
# $1: channel ( stable/incubator/test)
# $2: app name
function helm_install_with_config {
  # Copy the template
  cp -f "configs/$1/$2.tpl.yaml" "configs/$1/$2.yaml"

  # Replace the host domain
  sedeasy "HOST_IPv4" "$HOST_IPv4" "configs/$1/$2.yaml"
  sedeasy "HOST_IPv6" "$HOST_IPv6" "configs/$1/$2.yaml"

  helm install \
    --name "$2" \
    -f "configs/$1/$2.yaml" \
    "$1/$2" &>/dev/null
}

# Wait until POD is Running
function wait_until_pod_is_running {
  # Wait until the docker is up and running
  # echo -n ">> Waiting for '$1' to start..."
  status=`kubectl get pods --all-namespaces -l $2 -o jsonpath="{.items[0].status.phase}" | grep Running`
  while [ "$status" != "Running" ]
  do
    #echo -n "."
    sleep 0.5
    status=`kubectl get pods --all-namespaces -l $2 -o jsonpath="{.items[0].status.phase}" | grep Running`
  done
  # echo "started!"
}

# Install requires dependencies
echo ">> Installing dependencies..."
PACKAGES="ebtables ethtool socat docker kubeadm-bin kubectl-bin kubelet-bin kubernetes-helm-bin"
if [ -f "/etc/arch-release" ]; then
  # Install apacman
  yes '' | pacman -U --noprogressbar --noconfirm --needed deps/apacman-3.1-1-any.pkg.tar &>/dev/null
  # Install packages
  yes '' | pacman -Sy &>/dev/null
  yes '' | apacman -S --noconfirm --noedit --needed $PACKAGES &>/dev/null
else
  echo "[WARNING] It seems you are not running Arch Linux. Please make sure the following packages are installed: $PACKAGES"
fi

# Enable required services
echo ">> Enabling required services..."
# Docker
systemctl enable docker.service &>/dev/null
systemctl start docker.service &>/dev/null
# Kubelet
systemctl enable kubelet.service &>/dev/null
systemctl start kubelet.service &>/dev/null

# Enable support for systems with swap enabled
echo ">> Enabling Swap support..."
# Add systemd conf file for the kubelet service
mkdir -p /etc/systemd/system/kubelet.service.d/
cat << EOF > /etc/systemd/system/kubelet.service.d/99-local-extras.conf
[Service]
Environment="KUBELET_EXTRA_ARGS=--fail-swap-on=false"
EOF
# Restart the kubelet service
systemctl daemon-reload
systemctl restart kubelet.service &>/dev/null

# Start Kubernetes
echo ">> Starting Kubernetes..."
kubeadm init &>/dev/null
# Finish the installation
mkdir -p $HOME/.kube
cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

# Security comes first
echo ">> Securing the installation..."
# Turning off auto-approval of Node Client Certificates
# See https://kubernetes.io/docs/admin/kubeadm/#turning-off-auto-approval-of-node-client-certificates
kubectl delete clusterrole kubeadm:node-autoapprove-bootstrap &>/dev/null
# Turning off public access to the cluster-info ConfigMap
# See https://kubernetes.io/docs/admin/kubeadm/#turning-off-public-access-to-the-cluster-info-configmap
kubectl -n kube-public delete rolebinding kubeadm:bootstrap-signer-clusterinfo &>/dev/null

# Install Pod network manager
echo ">> Installing pod network..."
# Add missing CNI plugins
CNI_VERSION='v0.5.2'
mkdir -p /opt/cni/bin
curl -fsSL "https://github.com/containernetworking/cni/releases/download/${CNI_VERSION}/cni-amd64-${CNI_VERSION}.tgz" | tar xvz -C /opt/cni/bin/ &>/dev/null
# Use WeaveNet ( see https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#pod-network )
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')" &>/dev/null
wait_until_pod_is_running "weave-net" "name=weave-net"
wait_until_pod_is_running "kube-dns" "k8s-app=kube-dns"

# Add Helm
echo ">> Installing Helm package manager..."
# Disable taint on master
kubectl taint nodes --all node-role.kubernetes.io/master- &>/dev/null
# Add Helm package manager support
kubectl -n kube-system create sa tiller &>/dev/null
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller &>/dev/null
helm init --service-account tiller &>/dev/null
# Wait until Tiller is ready
kubectl rollout status -w deployment/tiller-deploy --namespace=kube-system &>/dev/null
# Add helm uKube repository
helm repo add ukube https://ukube.github.io/charts/dist &>/dev/null

# Install Nginx Ingress Controller
echo ">> Instaling Nginx Ingress Controller..."
helm_install_with_config "stable" "nginx-ingress"
wait_until_pod_is_running "nginx-ingress-nginx-ingress-controller" "app=nginx-ingress,component=controller"
wait_until_pod_is_running "nginx-ingress-nginx-ingress-default-backend" "app=nginx-ingress,component=default-backend"

# Install the Let's Encrypt Controller
echo ">> Installing Let's Encrypt Controller..."
helm_install_with_config "stable" "kube-lego"
wait_until_pod_is_running "kube-lego" "app=kube-lego"

# Print friendly done message
echo "------------------------------------------------------"
echo "All right! Everything seems to be installed correctly."
echo ""
echo "Have a nice day!"
echo "------------------------------------------------------"