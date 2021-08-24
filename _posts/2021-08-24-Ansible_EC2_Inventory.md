---
title: ANSIBLE EC2.PY 를 이용한 AWS DYNAMIC INVENTORY 설정

toc: true
toc_sticky: true

categories:
  - devops  
tags:
  - Ansible
  - AWS
---

# AWS 클라우드의 ec2.py 를 활용하기 위한 Ansible 을 설정
  - AWS 의 Scale In/Out 등으로 서버의 정보가 실시간으로 변화하여 Inventory 를 실시간으로 생성

### Python 및 Ansible 설치(/W Miniconda)
  - Ansible 관련 Python 라이브러리 설치가 필요 하여 Miniconda 로 설치
  ```bash
    #wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    #sh Miniconda3-latest-Linux-x86_64.sh (별다른 설정 없이 Enter)
    #python
    Python 3.8.3 (default, May 19 2020, 18:47:26)
    [GCC 7.3.0] :: Anaconda, Inc. on linux
    Type "help", "copyright", "credits" or "license" for more information.
    >>>
    
    #pip install boto  또는 boto3
    #yum install ansible
  ```
### ec2.py 설정

  - ec2.py & ec2.ini Download
    - https://raw.githubusercontent.com/ansible/ansible/stable-2.9/contrib/inventory/ec2.py  ( python3 )
    - https://raw.githubusercontent.com/ansible/ansible/stable-2.9/contrib/inventory/ec2.ini
  - 환경 설정
    ```ini
    export AWS_ACCESS_KEY_ID='AK123'
    export AWS_SECRET_ACCESS_KEY='abc123'
    export EC2_INI_PATH=/path/to/ec2.ini
    ```
  - ec2.ini 파일 설정
    ```ini
    regions = all                                            # 확인할 리전
    regions_exclude = us-gov-west-1,cn-north-1    # 제외할 리전
    destination_variable = public_dns_name          # Dns 정보 (public OR private )
    vpc_destination_variable = ip_address            # Subnet 정보 ( public OR private ) 
    route53 = False                                       # route53 수집 여부
    cache_path = ~/.ansible/tmp                       # cache 파일 
    cache_max_age = 300                                # cache 유효 시간 ( 비활성화시 0 )
    rds = False                                              # rds 수집 여부
    ```

### ansible cfg 설정

  - ansible.cfg inventory 수정
    ```bash
    # vi /etc/ansible/ansible.cfg
    inventory = /path/to/ec2.py
    ```

### ec2.py CLI
  - list 확인
  ```bash
  # ec2.py --list
  ```
  - cache refresh
  ```bash
  # ec2.py --refresh-cache
  ```
  - ansible 실행
  ```bash
  #ansible -i ec2.py -m ping <Tag_Name>
  #ansible-playbook -i ec2.py test.yml
   * ansible.cfg 내 "inventory = /path/to/ec2.py" 지정시 -i ec2.py 생략
  ```

### Sudo 사용자 생성 및 키복사 (/w Playbook)
  - 패스워드 암호화(python3)
  ```bash
    # python -c "from passlib.hash import sha512_crypt; import getpass; print (sha512_crypt.encrypt(getpass.getpass()))"
    Password:
  ```
  - User 생성 및 SUDO 적용

  ```yaml
    - hosts: {AWS_TAG_NAME}
        gahter_facts: yes
        vars:
        password: "패스워드 암호화 값"
        tasks:
        - name : useradd & passwd
            user : name = testuser
                password={{password}}
                state=present
        - name : sudo add
            shell : "echo 'testuser ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/testuser"
  ```
  - Key 복사

  ```yaml
    - hosts: {AWS_TAG_NAME}
        become: yes
        become_user: root
        tasks:
        - name : Key Copy
        authorized_key :
            user: testuser
            key: "{{ lookup('file', '/root' + '/.ssh/id_rsa_pub') }}"
  ```

#### 기타 참고 URL : 
  - https://ansible-docs.readthedocs.io/zh/stable-2.0/rst/intro_dynamic_inventory.html
  - https://sodocumentation.net/ko/ansible/topic/3302/amazon-web-services%EC%99%80-%ED%95%A8%EA%BB%98-%EC%82%AC%EC%9A%A9%ED%95%98%EA%B8%B0
  - https://linux.systemv.pe.kr/ansible-ec2-py-%EB%A5%BC-%EC%9D%B4%EC%9A%A9%ED%95%9C-dynamic-inventory-%ED%99%9C%EC%9A%A9/#ec2py