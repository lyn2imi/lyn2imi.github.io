---
title: Grafana 고가용성 (HA/Cluster) 구성

toc: true
toc_sticky: true

categories:
  - devops  
tags:
  - grafana
---

# Grafana 고가용성(HA/Cluster) 구성

#### 구성 정보

![grafana_cluster1](/images/Grafana_cluster/grafana_cluster1.png)

#### DB 구성 (mysql)
- Grafana high availability를 구성 하기 위해서는 Mysql 또는 Postgres 등 데이터 베이스 구성 필요

- Mysql 구성 (Docker-compose) 
  ```yaml
  version : '3.1'

  services: 
  db:
      image: mysql:8.0.22
      container_name: mysql8
      command: --default-authentication-plugin=mysql_native_password
      restart: Always
      environment: 
      MYSQL_ROOT_PASSWORD: passwd
      MYSQL_DATABASE: glass
      TZ: Asia/Seoul
      ports:
      - "3306:3306"
      - "33060:33060"
      volumes:
      - data:/var/lib/mysql
      - conf.d:/etc/mysql/conf.d
      - root:/root
  volumes:
  data:
  conf.d:
  root:
  ```
- mysql start
  ```bash
  # docker-compose up -d
  ```
- grafana Database 생성
  ```sql
    CREATE DATABASE `grafana`
  ```

#### Grafana Cluster 구성 

- grafana.ini 파일 수정

  ```ini
    app_mode = production
    instance_name = grafana_clu                      # 두 서버 동일한 이름 으로 설정되어야 함

    [paths]

    [server]   # Grafana 정보
    protocol = http
    http_addr = 0.0.0.0
    http_port = 3001
    root_url = %(protocol)s://%(domain)s/grafana
    serve_from_sub_path = true                       # sub path 사용시 true

    [database]  # DB 정보

    type = mysql                                     
    host = 1.1.1.4:3306                              
    name = grafana                                   
    user = root                                      
    password = passwd                             

    max_idle_conn = 2
    max_open_conn = 0
    conn_max_lifetime = 14400

    [remote_cache]  # 동일한 세션 정보를 갖기 위한 설정(session cluster)
    type = database

    [session]
    provider = mysql
    provider_config = root:passwd@tcp(1.1.1.4:3306)/grafana

    [security]
    admin_user = admin
    admin_password = dlsvkr!234

    [snapshots]
    external_enabled = false

    [users]
    allow_sign_up = true
    allow_org_create = false
    auto_assign_org = true
    auto_assign_org_id = 1
    verify_email_enabled = true
    login_hit = Email Only ex) username@mail.com

    [auth]
    login_maximum_inactive_lifetime_days = 1
    login_maximum_lifetime_days = 1
    login_cookie_name = grafana_sess

    [auth.ldap]            #LDAP 설정시 적용 (ldap.toml 에 상세 설정)
    #enabled = true
    #allow_sign_up = true

    [smtp]                 # 메일 이용시 설정
    #enabled = true
    #host = mail.mail.com:25
    #user = root@mail.com
    #password =
    #cert_file =
    #key_file =
    #skip_verify = false
    #from_address = grafana@mail.com
    #from_name = Grafana
    #ehlo_identity =
    #startTLS_policy =

    [plugin.grafana-image-renderer]     # image-renderer 설정
    rendering_viewport_device_scale_factor = 5
    rendering_ignore_https_errors = false
    rendering_dumpio = true
    rendering_args = "--app-shell-host-window-size=800,600"
    rendering_viewport_max_width = 800
    rendering_viewport_max_height = 600

  ```
- Grafana Docker-compose 구성

  ```yaml
    version: "3"

    services:
      grafana:
        image: grafana/grafana:7.3.4
        container_name: grafana
        restart: always
        volumes:
          - ./config/grafana.ini:/etc/grafana/grafana.ini
        ports:
          - 3000:3000
        environment:
          GF_RENDERING_SERVER_URL: http://renderer:8081/render
          GF_RENDERING_CALLBACK_URL: http://grafana:3000/grafana
          GF_LOG_FILTERS: rendering:debug
          GF_RENDERER_PLUGIN_CHROME_BIN: /usr/bin/chromium-browser

      renderer:
        image: grafana/grafana-image-renderer:latest
        container_name: grafana-renderer
        restart: always
        ports:
          - 8081:8081
        environment:
          ENABLE_METRICS: 'true'
  ```

- Grafana Start
  ```yaml
    # docker-compose up -d

    # docker-compose logs -f

    grafana     | t=2021-08-31T04:26:59+0000 lvl=info msg="Registering plugin" logger=plugins id=speakyourcode-button-panel
    grafana     | t=2021-08-31T04:26:59+0000 lvl=info msg="Registering plugin" logger=plugins id=neocat-cal-heatmap-panel
    grafana     | t=2021-08-31T04:26:59+0000 lvl=info msg="Registering plugin" logger=plugins id=aceiot-svg-panel
    grafana     | t=2021-08-31T04:26:59+0000 lvl=info msg="Registering plugin" logger=plugins id=digrich-bubblechart-panel
    grafana     | t=2021-08-31T04:26:59+0000 lvl=info msg="Registering plugin" logger=plugins id=farski-blendstat-panel
    grafana     | t=2021-08-31T04:26:59+0000 lvl=info msg="Registering plugin" logger=plugins id=marcusolsson-hexmap-panel
    grafana     | t=2021-08-31T04:26:59+0000 lvl=info msg="Registering plugin" logger=plugins id=novatec-sdg-panel
    grafana     | t=2021-08-31T04:26:59+0000 lvl=info msg="Registering plugin" logger=plugins id=jdbranham-diagram-panel
    grafana     | t=2021-08-31T04:26:59+0000 lvl=info msg="Registering plugin" logger=plugins id=petrslavotinek-carpetplot-panel
    grafana     | t=2021-08-31T04:26:59+0000 lvl=info msg="Registering plugin" logger=plugins id=snuids-trafficlights-panel
    grafana     | t=2021-08-31T04:26:59+0000 lvl=info msg="Registering plugin" logger=plugins id=yesoreyeram-boomtable-panel
    grafana     | t=2021-08-31T04:26:59+0000 lvl=info msg="Registering plugin" logger=plugins id=cloudspout-button-panel
    grafana     | t=2021-08-31T04:26:59+0000 lvl=info msg="Registering plugin" logger=plugins id=grafana-image-renderer
    grafana     | t=2021-08-31T04:26:59+0000 lvl=info msg="Registering plugin" logger=plugins id=isaozler-paretochart-panel
    grafana     | t=2021-08-31T04:26:59+0000 lvl=info msg="Registering plugin" logger=plugins id=novalabs-annotations-panel
    grafana     | t=2021-08-31T04:26:59+0000 lvl=info msg="Registering plugin" logger=plugins id=yesoreyeram-boomtheme-panel
    grafana     | t=2021-08-31T04:26:59+0000 lvl=info msg="Registering plugin" logger=plugins id=aidanmountford-html-panel
    grafana     | t=2021-08-31T04:26:59+0000 lvl=info msg="Registering plugin" logger=plugins id=grafana-piechart-panel
    grafana     | t=2021-08-31T04:26:59+0000 lvl=info msg="Registering plugin" logger=plugins id=vonage-status-panel
    grafana     | t=2021-08-31T04:26:59+0000 lvl=info msg="Backend rendering via external http server" logger=rendering renderer=http
    grafana     | t=2021-08-31T04:26:59+0000 lvl=info msg="HTTP Server Listen" logger=http.server address=[::]:3000 protocol=http subUrl=/grafana socket=

  ```

- DB Table 생성 확인

  ![grafana_cluster2](/images/Grafana_cluster/grafana_cluster2.png)

### Nginx Proxy 구성

- Nginx.conf 구성

  ```json
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

        upstream grafana {
            server 1.1.1.2:3000; # grafana server 1
            server 1.1.1.3:3000; # grafana server 2
        }

        server {
            listen       80 default_server;
            listen  [::]:80 default_server;
            server_name  localhost;

            location /grafana/ {
                proxy_pass http://grafana/;
            }
        }


    }
  ```
- Nginx Docker-compose 구성

  ```yaml
    version: '2.2'

    services:
    nginx:
        image: nginx:1.19.2-alpine
        hostname: nginx
        volumes:
        - ./nginx.conf:/etc/nginx/nginx.conf:ro
        ports:
        - "80:80"
  ```

- Nginx Start
  ```yaml
    # docker-compose up -d
  ```
- URL 접속
  - http://1.1.1.1/grafana/
  
  ![grafana_cluster3](/images/Grafana_cluster/grafana_cluster3.png)

- 참고 URL : 
  - https://grafana.com/docs/grafana/latest/administration/set-up-for-high-availability/
  - https://grafana.com/docs/grafana/latest/administration/configuration/