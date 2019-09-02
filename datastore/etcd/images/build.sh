#!/bin/bash

IMAGE_TAG_PREFIX='prasoontelang'
ETCD_VERSION='v3.3.9'

docker build -t "${IMAGE_TAG_PREFIX}/etcdctl" --build-arg etcd_version=${ETCD_VERSION} etcdctl/.
docker build -t "${IMAGE_TAG_PREFIX}/etcdctl:${ETCD_VERSION}" --build-arg etcd_version=${ETCD_VERSION} etcdctl/.
