# sampleapp-kubernetes
Kubernetes YAML for the Sample App

To use the Sample App with Astra:

1) Deploy kubernetes cluster
2) Add cluster compute to Astra
3) Manage your apps

```
$ git clone https://github.com/mminichino/sampleapp-kubernetes
$ cd sampleapp-kubernetes
$ kubectl create -f sampleapp-stack-gke-astra.yaml
```

To create the sample app with ONTAP NAS storage via Trident:

1) Install kubernetes cluster and kubectl
2) Install Trident per documentation in namespace trident
3) Edit JSON as appropriate for target ONTAP system
4) Add Trident directory to PATH

```
$ git clone https://github.com/mminichino/sampleapp-kubernetes
$ cd sampleapp-kubernetes
$ tridentctl -n trident create backend -f ontap-nas-trident-sample.json
$ kubectl create -f storage-class-ontapnas.yaml
$ kubectl create -f sampleapp-stack-ontapnas.yaml
```

To run the sample app without Trident, rather with local storage:

1) Install OpenEBS into your cluster
2) Configure cStor and create a storage class called openebs-cstor
3) See example YAML files in the examples directory

```
$ git clone https://github.com/mminichino/sampleapp-kubernetes
$ cd sampleapp-kubernetes
$ kubectl create -f sampleapp-stack-openebs.yaml
```

To run the sample app with Helm:

1) Make sure that Helm is setup on your cluster
2) Make sure that you have a default Storage Class set
3) Make sure the namespace you use has Istio sidecar injection enabled

```
$ git clone https://github.com/mminichino/sampleapp-kubernetes
$ cd sampleapp-kubernetes
$ helm install ./sampleapp
```

To use the REST API to access the SampleApp:

```
$ git clone https://github.com/mminichino/sampleapp-kubernetes
$ cd sampleapp-kubernetes
$ bin/getSampleAppVisitors.sh -l -h x.y.x.z -p 31380
Username: admin
Password: 
Login successful.
Exported token.  Please rerun to query data.
$ bin/getSampleAppVisitors.sh
Reading cached credentials from /home/user/.demo/demo.token
1,1,10.32.0.1,Safari,12.1.2,Desktop,macOS Mojave,sampleapp-billowing-mule-5b7847db47-khfzh,1568244060210
2,2,10.32.0.1,Safari,12.1.2,Desktop,macOS Mojave,sampleapp-billowing-mule-5b7847db47-rdp9h,1568244067887
```

To create a namespace with Istio sidecar injection enabled:

```
$ kubectl create namespace sampledemo
$ kubectl label namespace sampledemo istio-injection=enabled
```

To access the app, use the Istio HTTP ingress gateway:

```
$ kubectl -n istio-system get service istio-ingressgateway
NAME                   TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)                                                                                                                                      AGE
istio-ingressgateway   LoadBalancer   10.100.7.19   <pending>     15020:30698/TCP,80:31380/TCP,443:31390
```

In this example the HTTP port is 31380 and the external IP is pending (meaning there is no external IP), so you can access the app via http://\<master node host IP\>:31380.  If an external IP is shown, access the app via http://\<external IP\>:31380.

If you choose to run this on NetApp Kubernetes Service, it is recommended to use the istioctl from the 1.0.0 release.

```
$ cd ~
$ curl -L https://git.io/getLatestIstio | ISTIO_VERSION=1.0.0 sh -
$ export PATH="~/istio-1.0.0/bin:$PATH"
$ which istioctl
```
The Windows istioctl 1.0.0 installer can be obtained [here](https://github.com/istio/istio/releases/download/1.0.0/istio-1.0.0-win.zip).

To install kubectl on macOS:

```
$ curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/darwin/amd64/kubectl
$ sudo cp kubectl /usr/local/bin
$ sudo chmod 555 /usr/local/bin/kubectl
```

To install kubectl on Linux:

```$xslt
$ curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
$ sudo cp kubectl /usr/local/bin
$ sudo chmod 555 /usr/local/bin/kubectl
```

To install kubectl on Windows, download the installer [here](https://storage.googleapis.com/kubernetes-release/release/v1.15.0/bin/windows/amd64/kubectl.exe).

Final note - as Windows PowerShell does not support POSIX shell style redirection, the kubectl/istioctl inject command must be done in two steps:
```
istioctl kube-inject -f sampleapp-stack-local.yaml > sampleapp-stack-local-inject.yaml
kubectl create -f sampleapp-stack-local-inject.yaml
```
