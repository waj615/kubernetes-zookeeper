Zookeeper on Kubernetes
=======================

[![Circle CI](https://circleci.com/gh/rainchasers/kubernetes-zookeeper.svg?style=svg)](https://circleci.com/gh/rainchasers/kubernetes-zookeeper)

[![Docker Repository on Quay](https://quay.io/repository/rainchasers/zookeeper/status "Docker Repository on Quay")](https://quay.io/repository/rainchasers/zookeeper)

Zookeeper v3.4.8 docker build suitable for Kubernetes deployment. Inspiration from [eliaslevy/docker-zookeeper](https://github.com/eliaslevy/docker-zookeeper) and [jplock/docker-zookeeper](https://github.com/jplock/docker-zookeeper). Used at modest scale in a non-critical production system to support [Rainchasers](http://rainchasers.com/).

**If you're after a battle-hardened proven large-scale production system I'd recommend [Exhibitor](https://github.com/Netflix/exhibitor/wiki) from Netflix instead, see [here for a quick intro to it's usage on GCE](https://cloudplatform.googleblog.com/2016/04/taming-the-herd-using-Zookeeper-and-Exhibitor-on-Google-Container-Engine.html).**

To create a reliable 3 node cluster...

Create Kubernetes Services
--------------------------

```
kubectl create -f kubernetes/zookeeper-1-service.yml
kubectl create -f kubernetes/zookeeper-2-service.yml
kubectl create -f kubernetes/zookeeper-3-service.yml
kubectl create -f kubernetes/zookeeper-service.yml
```

Check your services:

```
$ kubectl get services
NAME                     CLUSTER_IP       EXTERNAL_IP      PORT(S)                      SELECTOR                    AGE
zookeeper                10.147.252.54    <none>           2181/TCP                     app=zookeeper               11d
zookeeper-1              10.147.253.51    <none>           2181/TCP,2888/TCP,3888/TCP   app=zookeeper,server-id=1   12d
zookeeper-2              10.147.249.15    <none>           2181/TCP,2888/TCP,3888/TCP   app=zookeeper,server-id=2   11d
zookeeper-3              10.147.250.253   <none>           2181/TCP,2888/TCP,3888/TCP   app=zookeeper,server-id=3   11d
```

Create Kubernetes Replication Controllers
-----------------------------------------

```
kubectl create -f kubernetes/zookeeper-1-rc.yml
kubectl create -f kubernetes/zookeeper-2-rc.yml
kubectl create -f kubernetes/zookeeper-3-rc.yml
```

Now check to see that the replication controllers have started 3 running pods:

```
$ kubectl get pods
NAME                       READY     STATUS    RESTARTS   AGE
busybox                    1/1       Running   287        12d
zookeeper-1-sut2n          1/1       Running   0          1m
zookeeper-2-c3sd0          1/1       Running   0          57s
zookeeper-3-33ai4          1/1       Running   0          53s
```

```
$ kubectl logs zookeeper-1-sut2n
2016-04-24 21:47:47,385 [myid:1] - INFO  [/10.147.253.51:3888:QuorumCnxManager$Listener@541] - Received connection request /10.240.0.2:40507
2016-04-24 21:47:47,395 [myid:1] - INFO  [WorkerReceiver[myid=1]:FastLeaderElection@600] - Notification: 1 (message format version), 3 (n.leader), 0x0 (n.zxid), 0x1 (n.round), LOOKING (n.state), 3 (n.sid), 0x0 (n.peerEpoch) FOLLOWING (my state)
```

Verify Zookeeper Cluster with busybox Pod
-----------------------------------------

Next we use a busybox pod to test that the services are working. First we need to setup the busybox pod:

```
$ kubectl create -f - << EOF
apiVersion: v1
kind: Pod
metadata:
  name: busybox
  namespace: default
spec:
  containers:
  - image: busybox
    command:
      - sleep
      - "3600"
    imagePullPolicy: IfNotPresent
    name: busybox
  restartPolicy: Always
EOF
```

Then we can check the zookeeper state:

```
$ kubectl exec busybox printenv | grep ZOOKEEPER_SERVICE
ZOOKEEPER_SERVICE_PORT=2181
ZOOKEEPER_SERVICE_HOST=10.147.252.54
ZOOKEEPER_SERVICE_PORT_CLIENT=2181
$ echo ruok | kubectl exec -i busybox nc 10.147.252.54 2181
imok
$ echo stat | kubectl exec -i busybox nc 10.147.252.54 2181
Zookeeper version: 3.4.8--1, built on 02/06/2016 03:18 GMT
Clients:
 /10.144.1.1:53748[0](queued=0,recved=1,sent=0)

Latency min/avg/max: 0/0/0
Received: 2
Sent: 1
Connections: 1
Outstanding: 0
Zxid: 0x0
Mode: follower
Node count: 4
```

Monitoring the Zookeeper Cluster
--------------------------------

The same Docker container can be placed into monitoring mode using a `MYID` environment variable value of `monitor`. To launch on kubernetes: 

```
kubectl create -f kubernetes/zookeeper-monitor-rc.yml
```

This will log the output of the `mntr` command to each deployed node in your Zookeeper cluster as a formtaed JSON string that can be parsed and monitored by whatever your downstream log aggregation solution is.