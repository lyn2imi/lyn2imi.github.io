---
title: kubernetes 및 istio 설치

toc: true
toc_sticky: true

categories:
  - devops
tags:
  - kubernetes
  - istio
---

# kubernetes 및 istio 설치

# kubespray vs kubeadm vs KOPS 차이

## kubernates install(/w kubespray)

### kubespray

  - kubespray 란
    - GCE, Azure, OpenStack, AWS, vSphere, Packet (bare metal), Oracle Cloud Infrastructure (Experimental)/Baremetal 에 빠르고 손쉬운 K8s 설치 지원
    - Ansible playbook/inventory 등을 활용하여 구성
  - kubespray 지원 정보
    - a highly available cluster
    - composable attributes
    - support for most popular Linux distributions
    - Ubuntu 16.04, 18.04, 20.04
    - CentOS/RHEL/Oracle Linux 7, 8
    - Debian Buster, Jessie, Stretch, Wheezy
    - Fedora 31, 32
    - Fedora CoreOS
    - openSUSE Leap 15
    - Flatcar Container Linux by Kinvolk
    - continuous integration tests

### 설치 전 필요 요건

 - Ansible의 명령어를 실행하기 위해 Ansible v 2.9와 Python netaddr 라이브러리가 머신에 설치되어 있어야 한다
 - Ansible 플레이북을 실행하기 위해 2.11 (혹은 그 이상) 버전의 Jinja가 필요하다
 - 타겟 서버들은 docker 이미지를 풀(pull) 하기 위해 반드시 인터넷에 접속할 수 있어야 한다. 아니라면, 추가적인 설정을 해야 한다 (오프라인 환경 확인하기)
 - 타겟 서버들의 IPv4 포워딩이 활성화되어야 한다
 - SSH 키가 인벤토리의 모든 서버들에 복사되어야 한다
 - 방화벽은 관리되지 않는다. 사용자가 예전 방식대로 고유한 규칙을 구현해야 한다. 디플로이먼트 과정에서의 문제를 방지하려면 방화벽을 비활성화해야 한다
 - 만약 kubespray가 루트가 아닌 사용자 계정에서 실행되었다면, 타겟 서버에서 알맞은 권한 확대 방법이 설정되어야 한다. 그 뒤 ansible_become 플래그나 커맨드 파라미터들, --become 또는 -b 가 명시되어야 한다


### 필요 요건 설치 

- Ansible (/w tar.gz)
  - 버전 참고 : https://pypi.org/project/ansible/#files
  ```bash
  # wget https://files.pythonhosted.org/packages/81/b6/2f27c1b1b61b12b718375e79620da9d7b2cb9a07331fd455ee36cfb17734/ansible-4.6.0.tar.gz
  # tar xvf ansible-4.6.0.tar.gz
  ```

- Python 3.9 (/w Miniconda)

  ```bash
    # wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    # sh Miniconda3-latest-Linux-x86_64.sh

        Welcome to Miniconda3 py39_4.10.3

        In order to continue the installation process, please review the license
        agreement.
        Please, press ENTER to continue
        Do you accept the license terms? [yes|no]
        [no] >>> yes
        Miniconda3 will now be installed into this location:
        /root/miniconda3

        - Press ENTER to confirm the location
        - Press CTRL-C to abort the installation
        - Or specify a different location below

        [/root/miniconda3] >>> yes
        [no] >>> yes
        no change     /root/miniconda3/condabin/conda
        no change     /root/miniconda3/bin/conda
        no change     /root/miniconda3/bin/conda-env
        no change     /root/miniconda3/bin/activate
        no change     /root/miniconda3/bin/deactivate
        no change     /root/miniconda3/etc/profile.d/conda.sh
        no change     /root/miniconda3/etc/fish/conf.d/conda.fish
        no change     /root/miniconda3/shell/condabin/Conda.psm1
        no change     /root/miniconda3/shell/condabin/conda-hook.ps1
        no change     /root/miniconda3/lib/python3.9/site-packages/xontrib/conda.xsh
        no change     /root/miniconda3/etc/profile.d/conda.csh
        modified      /root/.bashrc

        ==> For changes to take effect, close and re-open your current shell. <==

        If you'd prefer that conda's base environment not be activated on startup,
        set the auto_activate_base parameter to false:

        conda config --set auto_activate_base false

        Thank you for installing Miniconda3!

    - 설치 확인
  
    # python
    Python 3.9.5 (default, Jun  4 2021, 12:28:51)
    [GCC 7.5.0] :: Anaconda, Inc. on linux
    Type "help", "copyright", "credits" or "license" for more information.
    >>>
  ```

- SSH 키복사 ssh-copy-id

- Repository clone 및 Python package install

  ```bash
    # git clone https://github.com/kubernetes-sigs/kubespray
        Cloning into 'kubespray'...
        remote: Enumerating objects: 56118, done.
        remote: Counting objects: 100% (1013/1013), done.
        remote: Compressing objects: 100% (515/515), done.
        remote: Total 56118 (delta 524), reused 856 (delta 436), pack-reused 55105
        Receiving objects: 100% (56118/56118), 16.29 MiB | 7.91 MiB/s, done.
        Resolving deltas: 100% (31641/31641), done.
    # cd kubespray
    # pip3 install -r requirements.txt
        Collecting ansible==3.4.0
        Downloading ansible-3.4.0.tar.gz (31.9 MB)
            |████████████████████████████████| 31.9 MB 21.9 MB/s
            :      :      :      :      :      :      :
        Successfully installed MarkupSafe-1.1.1 PyYAML-5.4.1 ansible-3.4.0 ansible-base-2.10.11 cryptography-2.8 jinja2-2.11.3 jmespath-0.9.5 netaddr-0.7.19 packaging-21.0 pbr-5.4.4 pyparsing-2.4.7 ruamel.yaml-0.16.10 ruamel.yaml.clib-0.2.4
    #
  ```

### kubernates install (/w kubspray)

- inventory 생성



- 
```bash
    #declare -a IPS=(180.70.98.61 180.70.98.62, 180.70.98.63)
    # CONFIG_FILE=inventory/glass/inventory.ini python3 contrib/inventory_builder/inventory.py ${IPS[@]}
        DEBUG: Adding group all
        DEBUG: Adding group kube_control_plane
        DEBUG: Adding group kube_node
        DEBUG: Adding group etcd
        DEBUG: Adding group k8s_cluster
        DEBUG: Adding group calico_rr
        DEBUG: adding host node1 to group all
        DEBUG: adding host node2 to group all
        DEBUG: adding host node3 to group all
        DEBUG: adding host node1 to group etcd
        DEBUG: adding host node2 to group etcd
        DEBUG: adding host node3 to group etcd
        DEBUG: adding host node1 to group kube_control_plane
        DEBUG: adding host node2 to group kube_control_plane
        DEBUG: adding host node1 to group kube_node
        DEBUG: adding host node2 to group kube_node
        DEBUG: adding host node3 to group kube_node

