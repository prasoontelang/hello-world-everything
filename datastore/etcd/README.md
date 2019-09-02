# Demo

- Bring up a 3 node kind cluster using the `kind.yaml` present in the root of the repo
- Perform a kustomize build to deploy the `etcd` cluster and an `etcdctl` to control the etcd cluster

    ```sh
    $ kustomize build . | kubectl apply -f -
    ```

- The etcd cluster will be deployed in the `hw-etcd` namespace

    ```sh
    $ kubectl -n hw-etcd get pods
    NAME                       READY   STATUS    RESTARTS   AGE
    etcd-0                     1/1     Running   0          8m53s
    etcd-1                     1/1     Running   0          8m37s
    etcd-2                     1/1     Running   0          8m34s
    etcdctl-54569f78cf-646jh   1/1     Running   0          8m53s
    ```

- The endpoint for etcdctl is the cluster IP from svc

    ```sh
    $ kubectl -n hw-etcd get svc
    NAME   TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
    etcd   ClusterIP   10.111.102.203   <none>        2379/TCP,2380/TCP   10m
    ```

- Using `etcdctl`

    ```sh
    $ kubectl -n hw-etcd exec -it etcdctl-54569f78cf-646jh /bin/bash

    root@etcdctl-54569f78cf-646jh:/# etcdctl --endpoints http://10.111.102.203:2379 member list
    2e80f96756a54ca9: name=etcd-0 peerURLs=http://etcd-0.etcd:2380 clientURLs=http://etcd-0.etcd:2379 isLeader=true
    7fd61f3f79d97779: name=etcd-1 peerURLs=http://etcd-1.etcd:2380 clientURLs=http://etcd-1.etcd:2379 isLeader=false
    b429c86e3cd4e077: name=etcd-2 peerURLs=http://etcd-2.etcd:2380 clientURLs=http://etcd-2.etcd:2379 isLeader=false
    ```

- Once the testing is completed, you could delete the namespace `hw-etcd` or perform the step below:

    ```sh
    $ kustomize build . | kubectl delete -f -
    namespace "hw-etcd" deleted
    service "etcd" deleted
    deployment.extensions "etcdctl" deleted
    statefulset.apps "etcd" deleted
    ```

# References

- The etcd-sts.yaml was inspired from [What Is Etcd and How Do You Set Up an Etcd Cluster](https://rancher.com/blog/2019/2019-01-29-what-is-etcd/)
- Installing etcdctl from [Github](https://github.com/etcd-io/etcd/releases/tag/v3.3.9)
