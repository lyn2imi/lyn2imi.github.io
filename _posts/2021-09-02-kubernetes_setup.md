---
title: 쿠버네티스

toc: true
toc_sticky: true

categories:
  - devops  
tags:
  - kube
---

# 쿠버네티스

## 쿠버네티스란 무엇인가?
[https://kubernetes.io/ko/docs/concepts/overview/what-is-kubernetes/](https://kubernetes.io/ko/docs/concepts/overview/what-is-kubernetes/)

## 쿠버네티스 구성 요소
[https://kubernetes.io/ko/docs/concepts/overview/components/](https://kubernetes.io/ko/docs/concepts/overview/components/)
- 쿠버네티스를 배포하면 클러스터를 얻는다.
- 쿠버네티스 클러스터는 컨테이너화된 애플리케이션을 실행하는 노드라고 하는 워커 머신의 집합. 모든 클러스터는 최소 한 개의 워커 노드를 가진다.
- 워커 노드는 애플리케이션의 구성요소인 파드를 호스트한다. 
- 컨트롤 플레인은 워커 노드와 클러스터 내 파드를 관리한다. 
- 프로덕션 환경에서는 일반적으로 컨트롤 플레인이 여러 컴퓨터에 걸쳐 실행되고, 클러스터는 일반적으로 여러 노드를 실행하므로 내결함성과 고가용성이 제공된다.

![다이어그램](https://d33wubrfki0l68.cloudfront.net/2475489eaf20163ec0f54ddc1d92aa8d4c87c96b/e7c81/images/docs/components-of-kubernetes.svg)

### 컨트롤 플레인 컴포넌트
- kube-apiserver
  - API 서버는 쿠버네티스 API를 노출하는 쿠버네티스 컨트롤 플레인 컴포넌트
- etcd
  - 모든 클러스터 데이터를 담는 쿠버네티스 뒷단의 저장소로 사용되는 일관성·고가용성 키-값 저장소
- kube-scheduler
  - 노드가 배정되지 않은 새로 생성된 파드 를 감지하고, 실행할 노드를 선택하는 컨트롤 플레인 컴포넌트.
- kube-controller-manager
  - 컨트롤러 프로세스를 실행하는 컨트롤 플레인 컴포넌트.
- cloud-controller-manager
  - 클라우드별 컨트롤 로직을 포함하는 쿠버네티스 컨트롤 플레인 컴포넌트

### 노드 컴포넌트
- 노드 컴포넌트는 동작 중인 파드를 유지시키고 쿠버네티스 런타임 환경을 제공하며, 모든 노드 상에서 동작한다.

- kubelet
  - 클러스터의 각 노드에서 실행되는 에이전트. Kubelet은 파드에서 컨테이너가 확실하게 동작하도록 관리
- kube-proxy
  - 클러스터의 각 노드에서 실행되는 네트워크 프록시로, 쿠버네티스의 서비스 개념의 구현부
- 컨테이너 런타임
  - 컨테이너 실행을 담당하는 소프트웨어

### Kubernetes 설치 (/w rancher)
```bash
# docker run -d --restart=unless-stopped -p 8080:8080 rancher/server
Unable to find image 'rancher/server:latest' locally
latest: Pulling from rancher/server
bae382666908: Pull complete
29ede3c02ff2: Pull complete
da4e69f33106: Pull complete
8d43e5f5d27f: Pull complete
b0de1abb17d6: Pull complete
422f47db4517: Pull complete
79d37de643ce: Pull complete
69d13e08a4fe: Pull complete
2ddfd3c6a2b7: Pull complete
bc433fed3823: Pull complete
b82e188df556: Pull complete
dae2802428a4: Pull complete
07bf18e8eec0: Pull complete
339e24088f91: Pull complete
9372455de0b8: Pull complete
5a33b348bf45: Pull complete
3286997d8874: Pull complete
bd79bfb954de: Pull complete
ba7c19991a31: Pull complete
0c19aca4f8a1: Extracting [==================================================>]  105.1MB/105.1MB
```


```bash
# sudo docker run -e CATTLE_AGENT_IP="http://180.70.98.64/"  --rm --privileged -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/rancher:/var/lib/rancher rancher/agent:v1.2.11 http://180.70.98.64:8080/v1/scripts/F35AC4B2D8E6887073FE:1609372800000:YQz1B7JbDF2NgFkRLWB7ENU3rA
Unable to find image 'rancher/agent:v1.2.11' locally
v1.2.11: Pulling from rancher/agent
b3e1c725a85f: Extracting [================================>                  ]  32.51MB/50.22MB
6a710864a9fc: Download complete
d0ac3b234321: Download complete
87f567b5cf58: Download complete
063e24b217c4: Waiting
d0a3f58caef0: Waiting
16914729cfd3: Waiting
bbad862633b9: Waiting
3cf9849d7f3c: Waiting
```

```bash
(base) [root@kibana64 ~]# sudo docker run -e CATTLE_AGENT_IP="http://180.70.98.64/"  --rm --privileged -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/rancher:/var/lib/rancher rancher/agent:v1.2.11 http://180.70.98.64:8080/v1/scripts/F35AC4B2D8E6887073FE:1609372800000:YQz1B7JbDF2NgFkRLWB7ENU3rA
ERROR: Invalid CATTLE_AGENT_IP (http://180.70.98.64/)
(base) [root@kibana64 ~]# sudo docker run -e CATTLE_AGENT_IP="180.70.98.64"  --rm --privileged -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/rancher:/var/lib/rancher rancher/agent:v1.2.11 http://180.70.98.64:8080/v1/scripts/F35AC4B2D8E6887073FE:1609372800000:YQz1B7JbDF2NgFkRLWB7ENU3rA

INFO: Running Agent Registration Process, CATTLE_URL=http://180.70.98.64:8080/v1
INFO: Attempting to connect to: http://180.70.98.64:8080/v1
INFO: http://180.70.98.64:8080/v1 is accessible
INFO: Configured Host Registration URL info: CATTLE_URL=http://180.70.98.64:8080/v1 ENV_URL=http://180.70.98.64:8080/v1
INFO: Inspecting host capabilities
INFO: Boot2Docker: false
INFO: Host writable: true
INFO: Token: xxxxxxxx
INFO: Running registration
INFO: Printing Environment
INFO: ENV: CATTLE_ACCESS_KEY=1191885250D9253DFEB6
INFO: ENV: CATTLE_AGENT_IP=180.70.98.64
INFO: ENV: CATTLE_HOME=/var/lib/cattle
INFO: ENV: CATTLE_REGISTRATION_ACCESS_KEY=registrationToken
INFO: ENV: CATTLE_REGISTRATION_SECRET_KEY=xxxxxxx
INFO: ENV: CATTLE_SECRET_KEY=xxxxxxx
INFO: ENV: CATTLE_URL=http://180.70.98.64:8080/v1
INFO: ENV: DETECTED_CATTLE_AGENT_IP=10.1.0.1
INFO: ENV: RANCHER_AGENT_IMAGE=rancher/agent:v1.2.11
INFO: Launched Rancher Agent: 0a09bdcc63119226203e071eac7e23e3d3acbf246a6fb53e6c67f7676bb1bec3
```




> [root@elastic61 ~]# curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   154  100   154    0     0    337      0 --:--:-- --:--:-- --:--:--   337
100 44.7M  100 44.7M    0     0  12.6M      0  0:00:03  0:00:03 --:--:-- 19.5M
[root@elastic61 ~]# curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   154  100   154    0     0    431      0 --:--:-- --:--:-- --:--:--   431
100    64  100    64    0     0     86      0 --:--:-- --:--:-- --:--:--    86
[root@elastic61 ~]# echo "$(<kubectl.sha256) kubectl" | sha256sum --check
kubectl: 성공
[root@elastic61 ~]# sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
[root@elastic61 ~]# kubectl version --client
Client Version: version.Info{Major:"1", Minor:"22", GitVersion:"v1.22.1", GitCommit:"632ed300f2c34f6d6d15ca4cef3d3c7073412212", GitTreeState:"clean", BuildDate:"2021-08-19T15:45:37Z", GoVersion:"go1.16.7", Compiler:"gc", Platform:"linux/amd64"}
[root@elastic61 ~]# cat <<EOF > /etc/yum.repos.d/kubernetes.repo
> [kubernetes]
> name=Kubernetes
> baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
> enabled=1
> gpgcheck=1
> repo_gpgcheck=1
> gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
> EOF
yum install -y kubectl[root@elastic61 ~]# yum install -y kubectl
Loaded plugins: fastestmirror, langpacks
Repodata is over 2 weeks old. Install yum-cron? Or run: yum makecache fast
base                                                                                                                                                                   | 3.6 kB  00:00:00
docker-ce-stable                                                                                                                                                       | 3.5 kB  00:00:00
elasticsearch-6.x                                                                                                                                                      | 1.3 kB  00:00:00
elasticsearch-7.x                                                                                                                                                      | 1.3 kB  00:00:00
epel/x86_64/metalink                                                                                                                                                   | 9.5 kB  00:00:00
epel                                                                                                                                                                   | 4.7 kB  00:00:00
extras                                                                                                                                                                 | 2.9 kB  00:00:00
kubernetes/signature                                                                                                                                                   |  844 B  00:00:00
kubernetes/signature                                                                                                                                                   | 1.4 kB  00:00:00 !!!
updates                                                                                                                                                                | 2.9 kB  00:00:00
(1/9): docker-ce-stable/x86_64/primary_db                                                                                                                              |  63 kB  00:00:00
(2/9): epel/x86_64/group_gz                                                                                                                                            |  96 kB  00:00:00
(3/9): elasticsearch-7.x/primary                                                                                                                                       | 315 kB  00:00:00
(4/9): extras/7/x86_64/primary_db                                                                                                                                      | 242 kB  00:00:00
epel/x86_64/primary_db         FAILED
https://download.nus.edu.sg/mirror/epel/7/x86_64/repodata/d21b2b6565307c340972c407143288ae35b3baa73151d1e653753d87cdecab1c-primary.sqlite.bz2: [Errno 14] curl#22 - "The requested URL returned error: 403"
Trying other mirror.
(5/9): kubernetes/primary                                                                                                                                              |  95 kB  00:00:00
(6/9): elasticsearch-6.x/primary                                                                                                                                       | 290 kB  00:00:01
(7/9): epel/x86_64/primary_db                                                                                                                                          | 6.9 MB  00:00:01
(8/9): updates/7/x86_64/primary_db                                                                                                                                     |  10 MB  00:00:01
(9/9): epel/x86_64/updateinfo                                                                                                                                          | 1.0 MB  00:00:02
Determining fastest mirrors
 * base: mirror.kakao.com
 * epel: mirrors.ustc.edu.cn
 * extras: mirror.kakao.com
 * updates: mirror.kakao.com
elasticsearch-6.x                                                                                                                                                                     796/796
elasticsearch-7.x                                                                                                                                                                     972/972
kubernetes                                                                                                                                                                            702/702
Resolving Dependencies
--> Running transaction check
---> Package kubectl.x86_64 0:1.22.1-0 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

==============================================================================================================================================================================================
 Package                                      Arch                                        Version                                       Repository                                       Size
==============================================================================================================================================================================================
Installing:
 kubectl                                      x86_64                                      1.22.1-0                                      kubernetes                                      9.6 M

Transaction Summary
==============================================================================================================================================================================================
Install  1 Package

Total download size: 9.6 M
Installed size: 45 M
Downloading packages:
44f1e20edafb61bae2cbc459cfe421e5d837ea2349e712b54103b13b38ebb87b-kubectl-1.22.1-0.x86_64.rpm                                                                           | 9.6 MB  00:00:04
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Installing : kubectl-1.22.1-0.x86_64                                                                                                                                                    1/1
  Verifying  : kubectl-1.22.1-0.x86_64                                                                                                                                                    1/1

Installed:
  kubectl.x86_64 0:1.22.1-0

Complete!
