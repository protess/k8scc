# Kubernetes Crash Course

### What is Kubernetes

> **TL;DR:** 컨테이너 오케스트레이션 즉 컨테이너 배포및 관리를 쉽게 해준다

쿠버네티스는 컨테이너화된 워크로드와 서비스를 관리하기 위한 이식성이 있고, 확장가능한 오픈소스 플랫폼이다. 쿠버네티스는 선언적 구성과 자동화를 모두 용이하게 해준다. 쿠버네티스는 크고, 빠르게 성장하는 생태계를 가지고 있다. 쿠버네티스 서비스, 기술 지원 및 도구는 어디서나 쉽게 이용할 수 있다.

쿠버네티스란 명칭은 키잡이(helmsman)이나 파일럿을 뜻하는 그리스어에서 유래했다. 구글이 2014년에 쿠버네티스 프로젝트를 오픈소스화했다. 쿠버네티스는 구글의 15여년에 걸친 대규모 상용 워크로드 운영 경험을 기반으로 만들어졌으며 커뮤니티의 최고의 아이디어와 적용 사례가 결합되었다.

_subicura님의 **[쿠버네티스 시작하기 블로그](https://subicura.com/2019/05/19/kubernetes-basic-1.html)** 에서 발췌_  


**_[쿠버네티스 공식 한글 문서](https://kubernetes.io/ko/docs/concepts/overview/what-is-kubernetes/)_**  



### 컨테이너란?

> **TL;DR:** 매우 가볍고 stateless/ephemeral 한 VM 

컨테이너는 애플리케이션을 실제 구동 환경으로부터 추상화할 수 있는 논리 패키징 메커니즘을 제공합니다. 이러한 격리를 통해 사설 데이터 센터나 공용 클라우드, 심지어 개발자의 개인 노트북 컴퓨터에 이르기까지 어떤 환경으로든 컨테이너 기반 애플리케이션을 쉽게 지속적으로 배포할 수 있습니다. 또한 컨테이너화를 통해 업무 영역을 깔끔하게 분리할 수 있습니다. 즉, 개발자는 애플리케이션의 로직과 종속 항목에 집중할 수 있고, IT 부서는 특정 소프트웨어 버전과 개별 앱 구성과 관련한 세부 업무에 시간을 낭비하지 않고 배포 및 관리에 집중할 수 있습니다.

가상 환경에 익숙하다면 컨테이너를 가상 머신(VM)에 비교하여 생각하면 이해하기 쉽습니다. VM의 개념은 이미 익히 알고 계실 것입니다. 호스트 운영체제에서 구동되며 그 바탕이 되는 하드웨어에 가상으로 액세스하는 Linux, Windows 등의 게스트 운영체제를 의미합니다. 컨테이너는 가상 머신과 마찬가지로 애플리케이션을 관련 라이브러리 및 종속 항목과 함께 패키지로 묶어 소프트웨어 서비스 구동을 위한 격리 환경을 마련해 줍니다. 그러나 아래에서 살펴보듯 VM과의 유사점은 여기까지입니다. 컨테이너를 사용하면 개발자와 IT 운영팀이 훨씬 작은 단위로 업무를 수행할 수 있으므로 그에 따른 이점도 훨씬 많습니다.

**_[구글클라우드 문서](https://cloud.google.com/containers/?hl=ko)_** 에서 발췌:  


이어형님 **_[발표자료](https://engineering.linecorp.com/ko/blog/immutable-kubernetes-architecture-deepdive/):_**  


**Must Read:** _Dockerfile **[Best Practices](https://bit.ly/dockerbp)**_

## Preliminary Steps

### Install _[Homebrew]_
맥용 패키지툴 **Must Have!**

    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"


### Install Docker

It's **_docker_** enuf said.

Install **_[docker for mac](https://docs.docker.com/docker-for-mac/install/)._**  
Follow **_[docker guide](https://docs.docker.com/docker-for-mac/#advanced)_** to increase resource limit(need to set memory to 8GB+).


### Install Golang
Install **_Go_** with **_[gvm]:_**


    bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)

    gvm install go1.12
or Download from **_[golang.org]:_**  


### Add alias to kubectl
_개편함_

    alias k='kubectl'

### Install KIND
**_[KIND]_** 도커에 쿠버네티스 클러스터를 생성해주는 툴 _easy mode_


    GO111MODULE="on" go get sigs.k8s.io/kind@v0.4.0

    export PATH="$PATH:$(go env GOPATH)/bin"


## Let's create a k8s cluster

### Create k8s multi-node cluster with KIND

    kind create cluster --name kind-m --config kind-test-config.yaml

### Change k8s config  
Add configs from _'.kube/kind-config-kind-m'_ to _'.kube/config'_ file
or:

    export KUBECONFIG="$(kind get kubeconfig-path --name="kind-m")"

> **Note**: k8s config 은 다수의 context(clusters) 를 가질수 있습니다.
### Verify k8s cluster

    k cluster-info
    k get nodes
    k get pods --all-namespaces

## Play with k8s

### Web UI(Dashboard)
#### Install _[dashboard]:_

    kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta1/aio/deploy/recommended.yaml

    ### Run below to fix auth
    k apply -f ./dashboard
    
    ### Run below and copy hash code from token:  
    ./dashboard/getsecret.sh
    
    ### Run below from another terminal:
    k proxy

Click this **_[link](http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/)_** to open dashboard

#### Extra step:
To _disable_ session time-out:

    kubens kubernetes-dashboard
    k edit deployment kubernetes-dashboard

    ### add following after arg:
    - args:
      - --token-ttl=0

### Stateful Sets
실행 순서를 보장 호스트 이름과 볼륨을 일정하게 정하는것이 가능(데이터베이스 같은 앱에 유용)하다.

#### Deploy MariaDB(MySQL) for Wordpress
Deploy _MariaDB:_
    
    k create namespace wordpress
    k apply -f ./mysql

Check _Stateful Sets:_

    kubens wordpress
    k get sts
    k describe sts mysql

### Deployments

디플로이먼트는 _stateless/ephemeral_ 한 앱을 배포할때 사용하는 가장 기본적인 컨트롤러입니다.

**_[arisu's blog](https://arisu1000.tistory.com/27833)_** 참조

#### Deploy Wordpress

Deploy and edit wordpress:

    k apply -f ./wordpress

Scale in/out Deployments:

    k scale deploy wordpress --replicas=3
    k scale deploy wordpress --replicas=1

### Services
로드 밸런서와 같은 역할 포드들을 외부 네트워크와 연결해준다(디스커버리 역할도 함).   
이미 서비스는 위에서 실행했으니 확인해본다:

    k get svc


### ~ commands

    k version --short
    k api-resources
    k explain deployment --recursive
    k explain svc --recursive
    k get pods -o wide --sort-by="{.spec.nodeName}" --all-namespaces

## Endgame

### ⌫
    k --namespace=wordpress delete --all
    k delete --namespace wordpress

### rm -rf /

    kind delete cluster --name kind-m

## mU57 H4ve CL1 700L2
shell **_[auto-completion]_**(쉘에서 자동완성 기능)  
**_[kubectx/kubens]_**(k8s context swith 그리고 k8s namespace 체인져)  
**_[kube ps1](https://github.com/jonmosco/kube-ps1)_**(쉘 프롬프트에서 k8s를 사용하기 편하게 꾸며준다)  

## Something you may want to try

### Autoscaler

    ### not tested it may not work properly
    k apply -f ./extra


## Glossary

k8s = 쿠버네티스, k와 s사이에 8개의 알파벳이 있어서 k8s  
kubectl = 큐브커들 또는 큐브씨티엘, 쿠버네티스 cli 커맨드 툴  
kubeadm = 큐브애드민, 쿠버네티스 클러스터 생성해주는 툴  
kubelet = 큐브렛, 노드의 pod 관리툴  
kube-proxy = 큐브 프록시, pod 네트워크 관리툴  
etcd = 앳씨디, key-value 스토어 여기에 모든 클러스터 state 가 저장된다  
TL;DR = Too long didn't read : 읽기 매우 귀찮은 사람들을 위한  
1337 = **_[leet]_**

[leet]:
https://namu.wiki/w/%EB%A6%AC%ED%8A%B8

[kubectx/kubens]:
https://github.com/ahmetb/kubectx

[auto-completion]:
https://kubernetes.io/docs/tasks/tools/install-kubectl/?source=#enabling-shell-autocompletion

[dashboard]:
https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/

[HELM]:
https://helm.sh/docs/using_helm/

[KIND]:
https://kind.sigs.k8s.io/docs/user/quick-start

[golang.org]:
https://golang.org/dl/

[gvm]:
https://github.com/moovweb/gvm

[Homebrew]:
https://brew.sh/
