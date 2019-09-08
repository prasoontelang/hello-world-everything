# MySQL Server Standalone on Kubernetes

## Demo

0. Bring up a kind cluster using the `kind.yaml` present in the root of the repo
0. Perform a kustomize build to deploy `mysql` database and `mysql-client` to use mysql database.
    ```sh
    $ kustomize build . | kubectl apply -f -
    ```
0. The mysql will be deployed in the `hw-mysql-standalone` namespace
   ```sh
   $ kubectl -n hw-mysql-standalone get pods
   NAME                            READY   STATUS    RESTARTS   AGE
   mysql-799956477c-dtqzh          1/1     Running   0          54m
   mysql-client-7c48b57769-87nzd   1/1     Running   0          65m
   ```
0. Specify the service name as the hostname for mysql client to connect:
   ```sh
   $ kubectl -n hw-mysql-standalone exec -it mysql-client-7c48b57769-87nzd -- mysql -h mysql -ppassword

   [ ... MySQL welcome mesage ... ]
   mysql >
   ```

## Simple SQL operations

We will create some rows to be stored persistently in the DB.

```
mysql> create database helloworld;
Query OK, 1 row affected (0.00 sec)

mysql> use helloworld;
Database changed

mysql> create table kubernetes (
    -> deployment_id INT NOT NULL,
    -> service_id VARCHAR(100) NOT NULL,
    -> PRIMARY KEY (deployment_id)
    -> );
Query OK, 0 rows affected (0.01 sec)

mysql> insert into kubernetes (deployment_id, service_id) values (101, "testing");
Query OK, 1 row affected (0.01 sec)

mysql> select * from kubernetes;
+---------------+------------+
| deployment_id | service_id |
+---------------+------------+
|           101 | testing    |
+---------------+------------+
1 row in set (0.01 sec)
```

## Demo for data persistence beyond delete

We will delete the mysql deployment to simulate pod terminating and restarting. This is to ensure
that the data is being persisted in the volume, not in the ephemeral volume in the pod.

```
$ kubectl -n hw-mysql-standalone get deployments
NAME           READY   UP-TO-DATE   AVAILABLE   AGE
mysql          1/1     1            1           12m
mysql-client   1/1     1            1           9m12s

$ kubectl -n hw-mysql-standalone delete deployment/mysql
deployment.extensions "mysql" deleted

$ kubectl -n hw-mysql-standalone get deployments
NAME           READY   UP-TO-DATE   AVAILABLE   AGE
mysql-client   1/1     1            1           9m20s
```

Going back to the mysql-client, the connection to server is gone!

```
mysql> select * from kubernetes;
ERROR 2013 (HY000): Lost connection to MySQL server during query
```

We will now recreate the deployment so to bring the mysql server deployment back:

```
$ kustomize build . | kubectl apply -f -
namespace/hw-mysql-standalone unchanged
service/mysql unchanged
deployment.apps/mysql created   <--- indicates the mysql server is being created
deployment.extensions/mysql-client unchanged
persistentvolume/mysql-pv-volume unchanged
persistentvolumeclaim/mysql-pv-claim unchanged
```

Retry the select sql query to fetch rows from kubernetes table
```
mysql> select * from kubernetes;
ERROR 2006 (HY000): MySQL server has gone away
No connection. Trying to reconnect...
Connection id:    1
Current database: helloworld

+---------------+------------+
| deployment_id | service_id |
+---------------+------------+
|           101 | testing    |
+---------------+------------+
1 row in set (0.01 sec)
```

We see the data successfully persist because of the persistent volume `mysql-pv-volume` and
persistent volume claim `mysql-pv-claim`

```sh
$ kubectl -n hw-mysql-standalone get pv,pvc
NAME                               CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                STORAGECLASS   REASON   AGE
persistentvolume/mysql-pv-volume   3Gi        RWO            Retain           Bound    hw-mysql-standalone/mysql-pv-claim   manual                  93m

NAME                                   STATUS   VOLUME            CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/mysql-pv-claim   Bound    mysql-pv-volume   3Gi        RWO            manual         92m
```

## Cleanup

If you just delete the namespace, the persistent volume is left behind:

```sh
$ kubectl -n hw-mysql-standalone get pv,pvc
NAME                               CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS     CLAIM                                STORAGECLASS   REASON   AGE
persistentvolume/mysql-pv-volume   3Gi        RWO            Retain           Released   hw-mysql-standalone/mysql-pv-claim   manual                  96m
```

Perform this additional step:
```sh
kubectl delete pv/mysql-pv-volume
persistentvolume "mysql-pv-volume" deleted
```

or delete using kustomize:

```sh
$ kustomize build . | kubectl delete -f - 
namespace "hw-mysql-standalone" deleted
service "mysql" deleted
deployment.apps "mysql" deleted
deployment.extensions "mysql-client" deleted
persistentvolume "mysql-pv-volume" deleted
persistentvolumeclaim "mysql-pv-claim" deleted
```

## References:

- Kubernetes docs [Run a Single-Instance Stateful Application](https://kubernetes.io/docs/tasks/run-application/run-single-instance-stateful-application/)
