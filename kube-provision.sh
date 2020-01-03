#!/bin/bash

echo I am provisioning
date > /etc/vagrant_provisioned_at

if ! dpkg -s iptables >/dev/null; then
    apt-get install -y --no-install-recommends iptables
    update-alternatives --set iptables /usr/sbin/iptables-legacy >/dev/null 2>&1
    update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy >/dev/null 2>&1
    update-alternatives --set arptables /usr/sbin/arptables-legacy >/dev/null 2>&1
    update-alternatives --set ebtables /usr/sbin/ebtables-legacy >/dev/null 2>&1
fi

if [ ! -f /etc/sysctl.d/bridge-nf-call-iptables.conf ]; then
    sysctl net.bridge.bridge-nf-call-iptables=1
    echo "net.bridge.bridge-nf-call-iptables = 1" > /etc/sysctl.d/bridge-nf-call-iptables.conf
fi

swapoff -a

dpkg -s apt-transport-https >/dev/null || apt-get install -y --no-install-recommends apt-transport-https
dpkg -s ca-certificates >/dev/null || apt-get install -y --no-install-recommends ca-certificates
dpkg -s curl >/dev/null || apt-get install -y --no-install-recommends curl
dpkg -s gnupg2 >/dev/null || apt-get install -y --no-install-recommends gnupg2
dpkg -s software-properties-common >/dev/null || apt-get install -y --no-install-recommends software-properties-common

curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -

if [ ! -f /etc/apt/sources.list.d/docker.list ]; then
  echo "deb [arch=amd64] https://download.docker.com/linux/debian \
     $(lsb_release -cs) stable" \
      | tee /etc/apt/sources.list.d/docker.list
  apt-get update
fi

dpkg -s docker-ce >/dev/null || apt-get install -y docker-ce=18.06.2~ce~3-0~debian
usermod -a -G docker vagrant
dpkg -s git >/dev/null || apt-get install -y --no-install-recommends git

if [ ! -f /etc/docker/daemon.json ]; then
    cat > /etc/docker/daemon.json <<EOF
{
    "exec-opts": ["native.cgroupdriver=systemd"],
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "100m"
    },
    "storage-driver": "overlay2"
}
EOF
      mkdir -p /etc/systemd/system/docker.service.d
      systemctl daemon-reload
      systemctl restart docker
fi

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

if [ ! -f /etc/apt/sources.list.d/kubernetes.list ]; then
    cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
    apt-get update
fi

dpkg -s kubelet >/dev/null || apt-get install -y --no-install-recommends kubelet
dpkg -s kubeadm >/dev/null || apt-get install -y --no-install-recommends kubeadm
dpkg -s kubectl >/dev/null || apt-get install -y --no-install-recommends kubectl

apt-mark hold kubelet kubeadm kubectl

# EOF
