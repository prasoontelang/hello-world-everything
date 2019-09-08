# hello-world-everything

### Install kubernetes kind cluster

```sh
$ kind create cluster --config kind.yaml

# verify that it's a three node deployment
$ export KUBECONFIG="$(kind get kubeconfig-path --name='kind')"

$ kubectl get nodes
NAME                 STATUS   ROLES    AGE     VERSION
kind-control-plane   Ready    master   2m49s   v1.13.4
kind-worker          Ready    <none>   2m34s   v1.13.4
kind-worker2         Ready    <none>   2m35s   v1.13.4
```

### Datastore

0. [ETCD on 3-node cluster](datastore/etcd/)
0. [MySQL Server Standalone](datastore/mysql/standalone/)
