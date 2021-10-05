# Elasticsearch

### Replicas Number 변경(Online)

```java
# PUT /my-index-000001/_settings
{
  "index" : {
    "number_of_replicas" : 1
  }
}
```

### Node 당 Shard 수(Online)

```java
# PUT _cluster/settings
{
    "transient": {
        "cluster.max_shards_per_node" : "10000"
    }
}
```

### 검색 최대 허용 Bucket(Online)
- 단일 응답에서 허용되는 최대 Bucket(Default: 65536)

```java
# PUT _cluster/settings
{
    "transient": {
        "search.max_buckets" : "500000"
    }
}
```

# Docker

### Docker Default Subnet 변경

 - default address 변경
    ```bash
    # cat /etc/docker/daemon.json
    {
        "default-address-pools": [
            {"base":"XXX.XXX.XXX.0/16","size":24} 
        ]   
    }
    ```
  - Docker service restart

    ```bash
    # sudo systemctl restart docker
    ```

  - Docker container restart
    ```bash
    # docker-compose down && docker-compose up -d

    # ip addr
    ```

  - Docker Bridge Network 지우기
    ```bash
      # docker network ls
      NETWORK ID          NAME                DRIVER              SCOPE
      46936f33d398        bridge              bridge              local
      8cbb2e604297        gitlab_default      bridge              local
      0b0bf4910972        host                host                local
      486c7b254c34        none                null                local


      - 1개 지우기
      # docker network rm 8cbb2e604297

      - 전체 지우기 
      # docker network prune 
      WARNING! This will remove all networks not used by at least one container.
      Are you sure you want to continue? [y/N] 
    ```

### Docker Json 로그(std out/err) 증가 처리

  - Docker 모든 컨테이너의 표준 출력(stdout 또는 stderr)의 무분별한 증가 발생
  - 생성 위치 ("data-root" : "/docker" 기존) : /docker/containers//-json.log
  - Docker 내의 옵션으로 용량 증가 제어 필요

  - 용량 증가 설정
    ```bash
    # cat <<EOF | sudo tee /etc/docker/daemon.json
    {
      "data-root": "/docker",
      "log-opts": {
        "max-size": "100m"
      },
      "default-address-pools": [
          {"base": "XXX.XXX.XXXX.0/16","size":24}
      ]
    }
    EOF
    ```
  - 참고 URL : https://docs.docker.com/config/containers/logging/json-file/

# Python

### Anaconda Python Upgrade
- 참고 URL : https://stackoverflow.com/questions/41535881/how-do-i-upgrade-to-python-3-6-with-conda

```bash
# conda install -c anaconda python=3.9





```








```bash
# conda update python
/home/USER/anaconda3/lib/python3.7/site-packages/requests/__init__.py:91: RequestsDependencyWarning: urllib3 (1.26.6) or chardet (3.0.4) doesn't match a supported version!
  RequestsDependencyWarning)
Collecting package metadata (current_repodata.json): done
Solving environment: |

Updating python is constricted by

anaconda -> requires python==3.7.4=h265db76_1

If you are sure you want an update of your package either try `conda update --all` or install a specific version of the package you want using `conda install <pkg>=<version>`
                                                                                                                                                                                            done

## Package Plan ##

  environment location: /home/USER/anaconda3

  added / updated specs:
    - python


The following packages will be downloaded:

    package                    |            build
    ---------------------------|-----------------
    backports.functools_lru_cache-1.6.4|     pyhd3eb1b0_0           9 KB
    backports.tempfile-1.0     |     pyhd3eb1b0_1          11 KB
    conda-4.10.3               |   py37h06a4308_0         2.9 MB
    conda-package-handling-1.7.3|   py37h27cfd23_1         881 KB
    future-0.18.2              |           py37_1         631 KB
    ------------------------------------------------------------
                                           Total:         4.4 MB

The following packages will be UPDATED:

  backports.functoo~                               1.5-py_2 --> 1.6.4-pyhd3eb1b0_0
  conda                                        4.8.0-py37_0 --> 4.10.3-py37h06a4308_0
  conda-package-han~                   1.6.0-py37h7b6447c_0 --> 1.7.3-py37h27cfd23_1
  future                                      0.17.1-py37_0 --> 0.18.2-py37_1

The following packages will be DOWNGRADED:

  backports.tempfile                               1.0-py_1 --> 1.0-pyhd3eb1b0_1

Proceed ([y]/n)? y


Downloading and Extracting Packages
future-0.18.2        | 631 KB    | ################################################################################################################################################### | 100%
backports.functools_ | 9 KB      | ################################################################################################################################################### | 100%
conda-package-handli | 881 KB    | ################################################################################################################################################### | 100%
backports.tempfile-1 | 11 KB     | ################################################################################################################################################### | 100%
conda-4.10.3         | 2.9 MB    | ################################################################################################################################################### | 100%
Preparing transaction: done
Verifying transaction: done
Executing transaction: done
$ python
Python 3.7.4 (default, Aug 13 2019, 20:35:49)
```


# Site 즐겨찾기

### 최고의 엔지니어를 쫓아내는 방법
- https://news.hada.io/weekly/202138