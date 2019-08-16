# sampleapp-kubernetes
Kubernetes YAML for the Sample App

To create the sample app with ONTAP NAS storage via Trident:

1) Install Trident per documentation in namespace trident
2) Edit JSON as appropriate for target ONTAP system
3) Add Trident and Istio bin directories to PATH

```
$ git clone https://github.com/mminichino/sampleapp-kubernetes
$ cd sampleapp-kubernetes
$ tridentctl -n trident create backend -f ontap-nas-trident-sample.json
$ kubectl create -f storage-class-ontapnas.yaml
$ kubectl create -f sampleapp-secrets.yaml
$ kubectl apply -f <(istioctl kube-inject -f sampleapp-stack.yaml)
$ kubectl create -f sampleapp-istio-gw.yaml
```

To run the sample app without Trident, rather with local storage:

```
$ kubectl create -f sampleapp-secrets.yaml
$ kubectl apply -f <(istioctl kube-inject -f sampleapp-stack-local.yaml)
$ kubectl create -f sampleapp-istio-gw.yaml
```

To access the app, use the Istio HTTP ingress gateway:

```
$ kubectl -n istio-system get service istio-ingressgateway
NAME                   TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)                                                                                                                                      AGE
istio-ingressgateway   LoadBalancer   10.100.7.19   <pending>     15020:30698/TCP,80:31380/TCP,443:31390
```

In this example the HTTP port is 31380, so you can access the app via http://\<master node IP\>:31380


