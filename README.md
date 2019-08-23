# Kubernetes Crash Course
## Prerequisite
> Requirement: Mac
### Docker

Install **_[docker for mac](https://docs.docker.com/docker-for-mac/install/)._**  
Follow **_[docker guide](https://docs.docker.com/docker-for-mac/#advanced)_** to increase resource limit(need to set memory to 8GB+).

### Go
Install **_Go_** download from **_[golang.org]_**  
You can manage **_Go_** verions with **_[gvm]_**

### Kubectl
    curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl

    chmod -x ./kubectl
    
    mv ./kubectl /usr/local/bin/kubectl
    
    alias k='kubectl'

### KIND


    GO111MODULE="on" go get sigs.k8s.io/kind@v0.5.0

    export PATH="$PATH:$(go env GOPATH)/bin"

### Useful Tools

kubectl command shell **[auto-completion]**  

    ### for oh-my-zsh
    plugins=(... kubectl)

k8s context/namespace changer **[kubectx/kubens]**  
Awesome k8s shell prompt **[kube ps1](https://github.com/jonmosco/kube-ps1)**  

## Practice

### Create k8s multi-node cluster with KIND

    kind create cluster --name kind-m --config kind-test-config.yaml

### Change k8s config  
Add configs from _'.kube/kind-config-kind-m'_ to _'.kube/config'_ file
or:

    export KUBECONFIG="$(kind get kubeconfig-path --name="kind-m")"

> **Note**: k8s _config_ file may contain multiple configs.
> 
### Verify k8s cluster

    k cluster-info
    k get nodes
    k get pods --all-namespaces

### Web UI(Dashboard)
Install **_[dashboard]:_**

    kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta1/aio/deploy/recommended.yaml

    ### Run below to fix auth
    k apply -f ./dashboard
    
    ### Run below and copy hash code from token:  
    ./dashboard/getsecret.sh
    
    ### Run below from another terminal:
    k proxy

Click this **_[link](http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/)_** to open dashboard in your web browser.

To _disable_ session time-out:

    kubens kubernetes-dashboard
    k edit deployment kubernetes-dashboard

    ### add following after arg:
    - args:
      - --token-ttl=0

### Install Ingress-nginx
Installation **_[Guide](https://kubernetes.github.io/ingress-nginx/deploy/)_**

    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml

    ### create service
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/cloud-generic.yaml

### Deploy MariaDB(MySQL) for Wordpress - Stateful Sets
Deploy _MariaDB:_
    
    k create namespace wordpress
    k apply -f ./mysql

    ### Check Stateful Sets
    kubens wordpress
    k get sts
    k describe sts mysql

### Deploy Wordpress - Deployment

Deploy _Wordpress:_

    ### get you local ip
    IP=$(ifconfig | grep "inet " | grep -Fv 127.0.0.1 | $IP=awk '{print $2}')

    ### replace ingress host with your IP
    sed -i.bak "s/host.*/host: www."$IP".xip.io/g" $PWD/wordpress/ingress.yaml
    
    k apply -f ./wordpress

    ### edit deployment
    k edit deploy wordpress


Scale in/out Deployments:

    k scale deploy wordpress --replicas=3
    k scale deploy wordpress --replicas=1

    ### check services for wordpress
    k get svc

    ### check ingress
    k get ingress

    ### other commands
    k explain deployment --recursive
    k explain svc --recursive
    k get pods -o wide --sort-by="{.spec.nodeName}"

### Expose & Test

Intall socat to expose 80/443 port:

    for port in 80 443
    do
        node_port=$(kubectl get service -n ingress-nginx ingress-nginx -o=jsonpath="{.spec.ports[?(@.port == ${port})].nodePort}")

        docker run -d --name kind-proxy-${port} \
        --publish 127.0.0.1:${port}:${port} \
        --link kind-m-control-plane:target \
        alpine/socat -dd \
        tcp-listen:${port},fork,reuseaddr tcp-connect:target:${node_port}
    done

Test with your own DNS:

    www.192.168.1.20.xip.io
    blog.192.168.1.20.xip.io


### Delete resources and cluster
    k --namespace=wordpress delete --all
    k delete --namespace wordpress

    kind delete cluster --name kind-m


## Extra

### Autoscaler

    ### not tested it may not work properly
    k apply -f ./extra

### Blogs and Documentations

subicura님의 **[쿠버네티스 시작하기 블로그](https://subicura.com/2019/05/19/kubernetes-basic-1.html)**  


**[Kubernetes Documentation(KR)](https://kubernetes.io/ko/docs/concepts/overview/what-is-kubernetes/)**  

K8S Deep Dive: API Server **_[Part1](https://blog.openshift.com/kubernetes-deep-dive-api-server-part-1/), [Part2](https://blog.openshift.com/kubernetes-deep-dive-api-server-part-2/), [Part3](https://blog.openshift.com/kubernetes-deep-dive-api-server-part-3a/)_**

**[Google Container(KR)](https://cloud.google.com/containers/?hl=ko)**  


이어형님 **_[딥다이브](https://engineering.linecorp.com/ko/blog/immutable-kubernetes-architecture-deepdive/)_**  


Dockerfile **[Best Practices](https://bit.ly/dockerbp)**


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
