FROM ubuntu:18.04

ARG etcd_version

COPY install.sh /tmp/install.sh

RUN /tmp/install.sh $etcd_version

CMD ["etcdctl", "--version"]
