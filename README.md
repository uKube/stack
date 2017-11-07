> This repository is a natural successor of https://github.com/julianxhokaxhiu/vps-powered-by-docker.

# vps-powered-by-kubernetes

Arch Linux setup script to obtain a full VPS with Automatic Reverse Proxy without pain

## Stack
- IPv4 ( IPv6 will come soon )
- [Docker](https://www.docker.com/)
- [Kubernetes](https://kubernetes.io/)
- [Weave Net](https://www.weave.works/docs/net/latest/kube-addon/) as pod network manager
- [Nginx Ingress](https://github.com/kubernetes/ingress-nginx) as Ingress Controller
- [kube-lego](https://github.com/jetstack/kube-lego) as Automatic SSL ACME provider
- [Helm](https://helm.sh/) as Kubernetes Package Manager

## Module
- [Kubernetes Dashboard](https://github.com/kubernetes/dashboard) ( [dashboard.lan.sh](modules/kubernetes-dashboard/dashboard.lan.sh) )

## Requirements
A clean Arch Linux install with SSH capability as root user ( or any user which has sudo powers ).

## Installation
```bash
wget https://github.com/julianxhokaxhiu/vps-powered-by-kubernetes/archive/master.zip
unzip master.zip && cd vps-powered-by-kubernetes-master
find ./ -name "*.sh" -exec chmod +x {} \;
./install.sh
```
> Remember to configure the [`LEGO_EMAIL`](configs/stable/kube-lego.tpl.yaml#L8) with your own email.

## Module setup
Edit the configuration variables to fit your needs, inside `config.tpl.yaml` on every module, then
```bash
./path/to/module/<module_name>.sh
# example ./modules/kubernetes-dashboard/dashboard.lan.sh
```

**WARNING:** Within this stack **every** module is configured to get an automatic LE HTTPS certificate, if the FQDN is accepted on LE side. If yes, your HTTP domain will be redirected to HTTPS in automatic as soon as the certificate is there.

## Performance monitoring

Take a look at this awesome article: https://sysdig.com/blog/monitoring-kubernetes-with-sysdig-cloud/

## Disclaimer
- The mapping of the domains to the Host IP is considered done already externally to this project ( through DNS Server or statically inside your `hosts` file )

