> This repository is a natural successor of https://github.com/julianxhokaxhiu/vps-powered-by-docker

# µKube Stack

Easy install script for Kubernetes stack with Nginx Ingress, ACME, Weave.net, Helm and many modules

## Stack
- [Arch Linux](https://www.archlinux.org/) ( as a preference, but you can use your preferred distro if you want )
- IPv4 ( IPv6 will come soon )
- [Docker](https://www.docker.com/)
- [Kubernetes](https://kubernetes.io/)
- [Weave Net](https://www.weave.works/docs/net/latest/kube-addon/) as pod network manager
- [Nginx Ingress](https://github.com/kubernetes/ingress-nginx) as Ingress Controller
- [kube-lego](https://github.com/jetstack/kube-lego) as Automatic SSL ACME provider
- [Helm](https://helm.sh/) as Kubernetes Package Manager

## Modules
- [Kubernetes Dashboard](https://github.com/kubernetes/dashboard) ( [dashboard.lan.sh](modules/kubernetes-dashboard/dashboard.lan.sh) )
- [Poste](https://poste.io) ( [mail.lan.sh](modules/mail-server/mail.lan.sh) )
- [WebDAV](https://hub.docker.com/r/idelsink/webdav/) ( [webdav.lan.sh](modules/webdav/webdav.lan.sh) )

## Requirements
A clean Arch Linux install with SSH capability as root user ( or any user which has sudo powers ).

## Installation
```bash
wget https://github.com/uKube/stack/archive/master.zip
unzip master.zip && cd stack-master
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

