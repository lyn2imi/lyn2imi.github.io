---
title: Minio Cluster 구성

toc: true
toc_sticky: true

categories:
  - devops  
tags:
  - Minio
---


# Minio 를 통한 분산(Distributed) 시스템 구축

### erasure code 통한 데이터 보호
- 노드/디스크 오류 등 문제 발생 으로 부터 데이터 보호를 위하여 Erasure Code 적용(최소 구성 디스크 4개)
- Easure Code Calculator를 통하여 사용 용량, 장애 보호 가능 노드 등 확인
  - https://min.io/product/erasure-code-calculator
- Erasure code sizing guide
  - https://github.com/minio/minio/blob/master/docs/distributed/SIZING.md

### 노드 분산을 통한 고가용성
- 단독 노드의 경우 서버 다운시 정상적인 서비스가 불가능
- Minio 를 m개의 서버와 n개의 디스크가 있는 분산형(Distributed) MinIO 설정 할 경우 m/2개의 서버 또는 m*n /2개 이상의 디스크가 온라인 상태인 한 데이터를 안전하게 보호


### Minio Cluster 구성 (/w Docker-Compose)
- 4Node / Node당 Disk 3 개 구성 테스트

- Minio Docker-compose
    ```yaml
    version: '3.7'

    # starts 4 docker containers running minio server instances.
    # using nginx reverse proxy, load balancing, you can access
    # it through port 9000.
    services:
    minio:
        image: minio/minio:RELEASE.2021-08-05T22-01-19Z
        hostname: minio-node1
        volumes:
        - /data001/minio_data:/data1
        - /data002/minio_data:/data2
        - /data003/minio_data:/data3
        ports:
        - "9000:9000"
        - "9001:9001"
        extra_hosts:
        - "minio-node1:1.1.1.1"
        - "minio-node2:1.1.1.2"
        - "minio-node3:1.1.1.3"
        - "minio-node4:1.1.1.4"
        environment:
        MINIO_ROOT_USER: minio
        MINIO_ROOT_PASSWORD: minio1234
        command: server http://prod-elastic1{1...4}:9000/data{1...3} --console-address :9001
        healthcheck:
        test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/live"]
        interval: 30s
        timeout: 20s
        retries: 3
    ```

- Minio Start
  - 전체 Node 를 실행 완료 후 Log 확인(전체 노드 실행 전까지 오류 발생 할수 있음)
  ```bash
  # docker-compose up -d
  ```
  
- Web 를 통한 Minio Console 접속
  - http://localhost:9001/
    ![console](/images/Minio_Cluster/console.png)

### Nginx 를 통한 Minio 노드 Proxy (/w Docker-Compose)

- Nginx Docker-compose

  ```yaml

    version: '2.2'

    # starts 4 docker containers running minio server instances.
    # using nginx reverse proxy, load balancing, you can access
    # it through port 9000.
    services:
    nginx:
        image: nginx:1.19.2-alpine
        hostname: nginx
        volumes:
        - ./nginx.conf:/etc/nginx/nginx.conf:ro
        extra_hosts:
        - "minio-node1:1.1.1.1"
        - "minio-node2:1.1.1.2"
        - "minio-node3:1.1.1.3"
        - "minio-node4:1.1.1.4"
        ports:
        - "9000:9000"
        - "9001:9001"
  ```
- nginx.conf 파일 정보

  ```ini
    user  nginx;
    worker_processes  auto;

    error_log  /var/log/nginx/error.log warn;
    pid        /var/run/nginx.pid;

    events {
        worker_connections  4096;
    }

    http {
        include       /etc/nginx/mime.types;
        default_type  application/octet-stream;

        log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                        '$status $body_bytes_sent "$http_referer" '
                        '"$http_user_agent" "$http_x_forwarded_for"';

        access_log  /var/log/nginx/access.log  main;
        sendfile        on;
        keepalive_timeout  600;

        # include /etc/nginx/conf.d/*.conf;

        upstream minio {
            server minio-node1:9000;
            server minio-node2:9000;
            server minio-node3:9000;
            server minio-node4:9000;            
        }

        upstream minioconsole {
            server minio-node1:9001;
            server minio-node2:9001;
            server minio-node3:9001;
            server minio-node4:9001;   
        }

        server {
            listen       9000;
            listen  [::]:9000;
            server_name  localhost;

            # To allow special characters in headers
            ignore_invalid_headers off;
            # Allow any size file to be uploaded.
            # Set to a value such as 1000m; to restrict file size to a specific value
            client_max_body_size 0;
            # To disable buffering
            proxy_buffering off;

            location / {
                proxy_set_header Host $http_host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $scheme;

                proxy_connect_timeout 300;
                # Default is HTTP/1, keepalive is only enabled in HTTP/1.1
                proxy_http_version 1.1;
                proxy_set_header Connection "";
                chunked_transfer_encoding off;

                proxy_pass http://minio;
            }
        }

        server {
            listen       9001;
            listen  [::]:9001;
            server_name  localhost;

            # To allow special characters in headers
            ignore_invalid_headers off;
            # Allow any size file to be uploaded.
            # Set to a value such as 1000m; to restrict file size to a specific value
            client_max_body_size 0;
            # To disable buffering
            proxy_buffering off;

            location / {
                proxy_set_header Host $http_host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $scheme;

                proxy_connect_timeout 300;
                # Default is HTTP/1, keepalive is only enabled in HTTP/1.1
                proxy_http_version 1.1;
                proxy_set_header Connection "";
                chunked_transfer_encoding off;

                proxy_pass http://minioconsole;
            }
        }


    }
  ```

- 참고 URL : 
  - Minio Cluster : https://docs.min.io/docs/distributed-minio-quickstart-guide.html
  - Nginx Proxy : https://docs.min.io/docs/setup-nginx-proxy-with-minio.html

- 구성시 고려 사항
  - All the nodes running distributed MinIO need to have same access key and secret key for the nodes to connect. To achieve this, it is recommended to export access key and secret key as environment variables, MINIO_ACCESS_KEY and MINIO_SECRET_KEY, on all the nodes before executing MinIO server command.
  - MinIO creates erasure-coding sets of 4 to 16 drives per set. The number of drives you provide in total must be a multiple of one of those numbers.
  - MinIO chooses the largest EC set size which divides into the total number of drives or total number of nodes given - making sure to keep the uniform distribution i.e each node participates equal number of drives per set.
  - Each object is written to a single EC set, and therefore is spread over no more than 16 drives.
  - All the nodes running distributed MinIO setup are recommended to be homogeneous, i.e. same operating system, same number of disks and same network interconnects.
  - MinIO distributed mode requires fresh directories. If required, the drives can be shared with other applications. You can do this by using a sub-directory exclusive to MinIO. For example, if you have mounted your volume under /export, pass /export/data as arguments to MinIO server.
  - The IP addresses and drive paths below are for demonstration purposes only, you need to replace these with the actual IP addresses and drive paths/folders.
  - Servers running distributed MinIO instances should be less than 15 minutes apart. You can enable NTP service as a best practice to ensure same times across servers.
  - MINIO_DOMAIN environment variable should be defined and exported for bucket DNS style support.
  - Running Distributed MinIO on Windows operating system is considered experimental. Please proceed with caution.