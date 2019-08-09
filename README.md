# Kubernetes Crash Course

### What is Kubernetes

> **TL;DR:** 컨테이너 오케스트레이션 즉 컨테이너 배포및 관리를 쉽게 해준다

쿠버네티스는 컨테이너화된 워크로드와 서비스를 관리하기 위한 이식성이 있고, 확장가능한 오픈소스 플랫폼이다. 쿠버네티스는 선언적 구성과 자동화를 모두 용이하게 해준다. 쿠버네티스는 크고, 빠르게 성장하는 생태계를 가지고 있다. 쿠버네티스 서비스, 기술 지원 및 도구는 어디서나 쉽게 이용할 수 있다.

쿠버네티스란 명칭은 키잡이(helmsman)이나 파일럿을 뜻하는 그리스어에서 유래했다. 구글이 2014년에 쿠버네티스 프로젝트를 오픈소스화했다. 쿠버네티스는 구글의 15여년에 걸친 대규모 상용 워크로드 운영 경험을 기반으로 만들어졌으며 커뮤니티의 최고의 아이디어와 적용 사례가 결합되었다.

쿠버네티스 한글 문서:  
https://kubernetes.io/ko/docs/concepts/overview/what-is-kubernetes/

쿠버네티스 기초 블로그:  
https://subicura.com/2019/05/19/kubernetes-basic-1.html


### 컨테이너란?

> **TL;DR:** 매우 가볍고 stateless/ephemeral 한 VM 

컨테이너는 애플리케이션을 실제 구동 환경으로부터 추상화할 수 있는 논리 패키징 메커니즘을 제공합니다. 이러한 격리를 통해 사설 데이터 센터나 공용 클라우드, 심지어 개발자의 개인 노트북 컴퓨터에 이르기까지 어떤 환경으로든 컨테이너 기반 애플리케이션을 쉽게 지속적으로 배포할 수 있습니다. 또한 컨테이너화를 통해 업무 영역을 깔끔하게 분리할 수 있습니다. 즉, 개발자는 애플리케이션의 로직과 종속 항목에 집중할 수 있고, IT 부서는 특정 소프트웨어 버전과 개별 앱 구성과 관련한 세부 업무에 시간을 낭비하지 않고 배포 및 관리에 집중할 수 있습니다.

가상 환경에 익숙하다면 컨테이너를 가상 머신(VM)에 비교하여 생각하면 이해하기 쉽습니다. VM의 개념은 이미 익히 알고 계실 것입니다. 호스트 운영체제에서 구동되며 그 바탕이 되는 하드웨어에 가상으로 액세스하는 Linux, Windows 등의 게스트 운영체제를 의미합니다. 컨테이너는 가상 머신과 마찬가지로 애플리케이션을 관련 라이브러리 및 종속 항목과 함께 패키지로 묶어 소프트웨어 서비스 구동을 위한 격리 환경을 마련해 줍니다. 그러나 아래에서 살펴보듯 VM과의 유사점은 여기까지입니다. 컨테이너를 사용하면 개발자와 IT 운영팀이 훨씬 작은 단위로 업무를 수행할 수 있으므로 그에 따른 이점도 훨씬 많습니다.

https://cloud.google.com/containers/?hl=ko

**Must Read:** _Dockerfile_ Best Practices https://bit.ly/dockerbp 

## Preliminary Steps

### Install Homebrew
_맥용 패키지툴 must have!_

    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"


### Install Docker

_It's docker enuf said._

Install Docker for Mac:  
https://docs.docker.com/docker-for-mac/install/

### Install Golang
Install Go with gvm:
https://github.com/moovweb/gvm

    bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)

    gvm install go1.12
or Download from golang.org:  
https://golang.org/dl/

### Add alias to kubectl
_개편함_

    export alias k='kubectl'

### Install KIND
_KIND 도커에 쿠버네티스 클러스터를 생성해주는 툴 -개쉬움-_

https://github.com/kubernetes-sigs/kind  

    GO111MODULE="on" go get sigs.k8s.io/kind@v0.4.0

    export PATH="$PATH:$(go env GOPATH)/bin"


## Let's create a k8s cluster

### Create k8s cluster with KIND

    kind create cluster

### Check k8s config  
_add configs from .kube/kind-config-kind to .kube/config file_

>Note: k8s config 은 다수의 context(clusters) 를 가질수 있습니다.
### Check k8s cluster nodes and pods

    k get nodes
    k get pods --all-namespaces

## Play with k8s

### Install HELM
    brew install kubernetes-helm
    helm init --history-max 200
### Web UI(Dashboard)
#### Install:
https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/

    kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta1/aio/deploy/recommended.yaml

#### Configure:
Run below command to make it work:

    k apply -f ./dashboard

#### Connect:

Run below command from terminal:

    k proxy

Open following link with your favorite browser:  
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

## Endgame

### Delete KIND

    kind delete cluster

## Glossary

k8s = 쿠버네티스, k와 s사이에 8개의 알파벳이 있어서 k8s  
kubectl = 큐브커틀 또는 큐브씨티엘, 쿠버네티스 cli 커맨드  
kubeadm = 큐브애드민, 쿠버네티스 클러스터 생성해주는 툴  
kubelet = 큐브렛, 노드의 pod 관리툴  
kube-proxy = 큐브 프록시, pod 네트워크 관리툴  
etcd = 앳씨디, key-value 스토어 여기에 모든 클러스터 state 가 저장된다  
TL;DR = Too long didn't read : 읽기 매우 귀찮은 사람들을 위한