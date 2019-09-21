# Kubernetes Crash Course

Kubernetes Crash Course Blog Post(KR) - no link yet

## Prerequisite
> _Requirement: Mac model 2010+, OS 10.12+_
### Docker

Install **_[docker for mac](https://docs.docker.com/docker-for-mac/install/)._**  
Follow **_[docker guide](https://docs.docker.com/docker-for-mac/#advanced)_** to increase resource limit(need to set memory to 8GB+).

### Go
Install **_Go_** download from **_[golang.org]_**  
You can manage **_Go_** verions with **_[gvm]_**

### Kubectl
    ### download kubectl 1.16.0
    curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.16.0/bin/darwin/amd64/kubectl

    chmod -x ./kubectl
    
    mv ./kubectl /usr/local/bin/kubectl

    ### if kubectl isn't executable
    chmod 755 /usr/local/bin/kubectl
    
### KIND

Refer to _**[KIND](https://github.com/kubernetes-sigs/kind)**_ for more details

    GO111MODULE="on" go get sigs.k8s.io/kind@v0.5.1

    export PATH="$PATH:$(go env GOPATH)/bin"

### Aliases

    alias k='kubectl'
    
    alias chrome="/Applications/Google\\ \\Chrome.app/Contents/MacOS/Google\\ \\Chrome"


### Useful Tools

_kubectl_ command shell _**[auto-completion]**_  

    ### for oh-my-zsh
    plugins=(... kubectl)

k8s context/namespace changer _**[kubectx/kubens]**_  
Awesome k8s shell prompt _**[kube ps1](https://github.com/jonmosco/kube-ps1)**_  
Very cool k8s CLI manage tool _**[k9s]**_


## Practice

### Create k8s multi-node cluster with KIND
Will create 1 master and 2 worker nodes.  

    kind create cluster --name kind-m --config kind-test-config.yaml

### Change k8s config  
Add configs from _'.kube/kind-config-kind-m'_ to _'.kube/config'_ file
or:

    export KUBECONFIG="$(kind get kubeconfig-path --name="kind-m")"

> **Note**: k8s _config_ file may contain multiple configs.
> 
### Verify k8s cluster

    kubectl cluster-info
    kubectl get nodes
    kubectl get pods --all-namespaces


### Install metrics-server
Refer to _**[metrics-server](https://github.com/kubernetes-incubator/metrics-server)**_ for more information

    kubectl apply -f ./metrics-server

### Install Ingress-nginx
Installation _**[Guide](https://kubernetes.github.io/ingress-nginx/deploy/)**_

    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml

    ### create service with nodeport 32080, 32433
    kubectl apply -f ./ingress-nginx/




### Deploy MariaDB(MySQL) for Wordpress - Stateful Sets
Deploy _MariaDB:_
    
    kubectl create namespace wordpress
    kubectl apply -f ./mysql

    ### Check Stateful Sets
    kubectl get sts -n wordpress
    kubectl describe sts mysql -n wordpress

### Deploy Wordpress - Deployment

Deploy _Wordpress:_

    ### get you local ip
    IP=$(ifconfig | grep "inet " | grep -Fv 127.0.0.1 | awk '{print $2}')

    ### replace ingress host with your IP
    sed -i.bak "s/host.*/host: blog."$IP".nip.io/g" ./wordpress/ingress.yaml
    
    kubectl apply -f ./wordpress

    ### edit deployment
    kubectl edit deploy wordpress

    ### port forward to check if wordpress is running correctly
    WPOD=$(kubectl get -n wordpress pod -l app=wordpress -o jsonpath="{.items[0].metadata.name}")

    kubectl port-forward pod/$WPOD 8090:80 -n wordpress


Scale in/out Deployments:

    kubectl scale deploy wordpress --replicas=3 -n wordpress
    kubectl scale deploy wordpress --replicas=1 -n wordpress

    ### check services for wordpress
    kubectl get svc -n wordpress

    ### check ingress
    kubectl get ingress -n wordpress

    ### other commands
    k explain deployment --recursive
    k explain svc --recursive
    k get pods -o wide --sort-by="{.spec.nodeName}"

### Expose Ingress
Intall _socat_ to expose nodeport on local 80 port:

    docker run -d --name kind-proxy-80 \
    --publish 80:80 \
    --link kind-m-control-plane:target \
    alpine/socat \
    tcp-listen:80,fork,reuseaddr tcp-connect:target:32080

### Test

Test with your own DNS:

    chrome http://blog.$IP.nip.io


### Delete resources and cluster
    kubectl --namespace=wordpress delete --all
    kubectl delete --namespace wordpress

    kind delete cluster --name kind-m

    ### remove socat
    docker rm -f kind-proxy-80


## Extra

### Web UI(Dashboard)
Install _**[dashboard]:**_

    kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta4/aio/deploy/recommended.yaml

    ### Run below to fix auth
    k apply -f ./dashboard
    
    ### Run below and copy hash code from token:  
    ./dashboard/getsecret.sh
    
    ### Run below from another terminal:
    k proxy

Click this _**[link](http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/)**_ to open dashboard in your web browser.

To _disable_ session time-out:

    kubectl edit deployment kubernetes-dashboard -n kube-system

    ### add following after arg:
    - args:
      - --token-ttl=0


### Autoscaler

    ### metrics-server must be running
    kubectl apply -f ./extra

### Blogs and Documentations

subicura님의 _**[쿠버네티스 시작하기 블로그](https://subicura.com/2019/05/19/kubernetes-basic-1.html)**_  


_**[Kubernetes Documentation(KR)](https://kubernetes.io/ko/docs/concepts/overview/what-is-kubernetes/)**_  

K8S Deep Dive: API Server _**[Part1](https://blog.openshift.com/kubernetes-deep-dive-api-server-part-1/), [Part2](https://blog.openshift.com/kubernetes-deep-dive-api-server-part-2/), [Part3](https://blog.openshift.com/kubernetes-deep-dive-api-server-part-3a/)**_

_**[Google Container(KR)](https://cloud.google.com/containers/?hl=ko)**_  


이어형님 _**[딥다이브](https://engineering.linecorp.com/ko/blog/immutable-kubernetes-architecture-deepdive/)**_  


Dockerfile _**[Best Practices](https://bit.ly/dockerbp)**_


[kubectx/kubens]:
https://github.com/ahmetb/kubectx

[auto-completion]:
https://kubernetes.io/docs/tasks/tools/install-kubectl/?source=#enabling-shell-autocompletion

[dashboard]:
https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/

[KIND]:
https://kind.sigs.k8s.io/docs/user/quick-start

[golang.org]:
https://golang.org/dl/

[gvm]:
https://github.com/moovweb/gvm

[Homebrew]:
https://brew.sh/

[k9s]:
https://k9ss.io/?fbclid=IwAR0MQO9yBF5iKpJlDkuSNtrWGy72zK81I-j071lrKQsV1DLhloOMknOLd64