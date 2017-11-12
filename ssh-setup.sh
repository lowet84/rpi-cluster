#!/bin/bash
if [ -z $1 ]; then
  echo "enter a name for the node"
  exit 1
fi

cd /root
mkdir .ssh
cd .ssh
wget https://gist.githubusercontent.com/lowet84/7c8e4375c55322ea770083a63a21b041/raw/aabc72b83e9efb376fe14d16b397ecb873fe4f0a/publickey -O authorized_keys
sed -i 's/#PasswordAuthentication\ yes/PasswordAuthentication\ no/g' /etc/ssh/sshd_config
sed -i "s/black-pearl/$1/g" /boot/device-init.yaml

apt-get update
apt-get install -y netfilter-persistent
mkdir -p /etc/iptables/

echo "*filter
:KUBE-SERVICES - [0:0]
-A FORWARD -i cni0 -j ACCEPT
-A FORWARD -o cni0 -j ACCEPT
-A FORWARD -i flannel.1 -j ACCEPT
-A FORWARD -o flannel.1 -j ACCEPT
COMMIT
" | sudo tee -a /etc/iptables/rules.v4 > /dev/null

sudo iptables -A FORWARD -i cni0 -j ACCEPT
sudo iptables -A FORWARD -o cni0 -j ACCEPT
sudo iptables -A FORWARD -i flannel.1 -j ACCEPT
sudo iptables -A FORWARD -o flannel.1 -j ACCEPT

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
apt-get update

apt-get install -y kubeadm


