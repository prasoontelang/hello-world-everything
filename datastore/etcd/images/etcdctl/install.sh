#!/bin/bash 

apt update -y
apt upgrade -y
apt install curl -y 

ETCD_VERSION=${1}

curl -L https://github.com/coreos/etcd/releases/download/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz -o etcd-${ETCD_VERSION}-linux-amd64.tar.gz

tar xzvf etcd-${ETCD_VERSION}-linux-amd64.tar.gz
rm etcd-${ETCD_VERSION}-linux-amd64.tar.gz

cd etcd-${ETCD_VERSION}-linux-amd64
cp etcd /usr/local/bin/
cp etcdctl /usr/local/bin/

rm -rf etcd-${ETCD_VERSION}-linux-amd64

etcdctl --version
