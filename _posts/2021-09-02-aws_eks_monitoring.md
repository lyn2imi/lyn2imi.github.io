---
title: AWS EKS Log 수집 및 S3/ELK 연동

toc: true
toc_sticky: true

categories:
  - devops  
tags:
  - AWS
  - EKS
  - Monitoring
  - ElasticStack
  - Fluntbit
---

# AWS EKS Log 수집 및 및 S3/ELK 구성

![aws_eks_monitoring_1](/images/aws_eks_monitoring/aws_eks_monitoring_1.png)

### Fluent Bit 란 ?
- fluentd 에서 경량화된 버전의 수집 프로세스
- data pipline

![aws_eks_monitoring_2](/images/aws_eks_monitoring/aws_eks_monitoring_2.png)

- input 정보
  - 정보를 수집하기위한 입력 플러그인, 로그 파일에서 데이터를 수집, 운영 체제에서 메트릭 정보를 수집

  - input
  - 정보를 수집하기위한 입력 플러그인, 로그 파일에서 데이터를 수집, 운영 체제에서 메트릭 정보를 수집

| Module              | 설명                                  | 상세                                                                  |
|---------------------|-------------------------------------|---------------------------------------------------------------------|
| Collectd            | Socket (Packet)                     | https://docs.fluentbit.io/manual/pipeline/inputs/collectd           |
| CPU Metrics         | CPU 사용률                             | https://docs.fluentbit.io/manual/pipeline/inputs/cpu-metrics        |
| Disk I/O Metrics    | disk throughput                     | https://docs.fluentbit.io/manual/pipeline/inputs/disk-io-metrics    |
| Docker Events       | docker API to capture server events | https://docs.fluentbit.io/manual/pipeline/inputs/docker-events      |
| Dummy               | dummy events                        | https://docs.fluentbit.io/manual/pipeline/inputs/dummy              |
| Exec                | 프로그램 실행 및 결과 로그                     | https://docs.fluentbit.io/manual/pipeline/inputs/exec               |
| Forward             | Fluentbit 또는 Fluentd 간의 메시지 라우팅     | https://docs.fluentbit.io/manual/pipeline/inputs/forward            |
| Head                | 파일의 특정 위치 이벤트(command head 와 유사)    | https://docs.fluentbit.io/manual/pipeline/inputs/head               |
| Health              | TCP Health 체크                       | https://docs.fluentbit.io/manual/pipeline/inputs/health             |
| Kernel Logs         | 커널 로그                               | https://docs.fluentbit.io/manual/pipeline/inputs/kernel-logs        |
| Memory Metrics      | 메모리 및 스왑 사용량                        | https://docs.fluentbit.io/manual/pipeline/inputs/memory-metrics     |
| MQTT                | MQTT 메시지 및 데이터 (데이터 포맷 Json)        | https://docs.fluentbit.io/manual/pipeline/inputs/mqtt               |
| Network I/O Metrics | 네트워크 트래픽                            | https://docs.fluentbit.io/manual/pipeline/inputs/network-io-metrics |
| Process             | 프로세스 상태 체크                          | https://docs.fluentbit.io/manual/pipeline/inputs/process            |
| Random              | 랜덤 임의 값 생성                          | https://docs.fluentbit.io/manual/pipeline/inputs/random             |
| Serial Interface    | 시리얼 메시지 및 데이터                       | https://docs.fluentbit.io/manual/pipeline/inputs/serial-interface   |
| Standard Input      | Std in (데이터 포맷 Json)                | https://docs.fluentbit.io/manual/pipeline/inputs/standard-input     |
| Syslog              | TCP/UDP Syslog 수집                   | https://docs.fluentbit.io/manual/pipeline/inputs/syslog             |
| Systemd             | Journald 발생하는 로그                    | https://docs.fluentbit.io/manual/pipeline/inputs/systemd            |
| Tail                | 로그 파일(command tail -f 와 유사)         | https://docs.fluentbit.io/manual/pipeline/inputs/tail               |
| TCP                 | TCP 통한 Json 메시지                     | https://docs.fluentbit.io/manual/pipeline/inputs/tcp                |
| Thermal             | 서버의 온도 (Only Linux)                 | https://docs.fluentbit.io/manual/pipeline/inputs/thermal            |
| Windows Event Log   | 윈도우 이벤트                             | https://docs.fluentbit.io/manual/pipeline/inputs/windows-event-log  |

- Parser :  
  - 입력된 데이터를 구조화

| Module             | 설명                                          | 상세                                                                   |
|--------------------|---------------------------------------------|----------------------------------------------------------------------|
| JSON               | 입력된 Json 포맷으로 구조화                           | https://docs.fluentbit.io/manual/pipeline/parsers/json               |
| Regular Expression | 정규 표현식으로 구조화                                | https://docs.fluentbit.io/manual/pipeline/parsers/regular-expression |
| LTSV               | LTSV 포맷( http://ltsv.org/ )의 구조화            | https://docs.fluentbit.io/manual/pipeline/parsers/ltsv               |
| Logfmt             | Logfmt 포맷(https://brandur.org/logfmt) 의 구조화 | https://docs.fluentbit.io/manual/pipeline/parsers/logfmt             |
| Decoders           | 메시지의 Decoding                               | https://docs.fluentbit.io/manual/pipeline/parsers/decoders           |

- Filter
  - 데이터를 특정 대상으로 전달하기 전 데이터를 변경

| Module          | 설명                                                 | 상세                                                                |
|-----------------|----------------------------------------------------|-------------------------------------------------------------------|
| AWS Metadata    | 레코드에 AWS 의 메타 데이터 추가                               | https://docs.fluentbit.io/manual/pipeline/filters/aws-metadata    |
| Expect          | 레코드에 예상 키와 값이 포함되어 있는지 확인 테스트                      | https://docs.fluentbit.io/manual/pipeline/filters/expect          |
| Grep            | 정규식 패턴을 기반으로 특정 레코드를 일치 시키거나 제외                    | https://docs.fluentbit.io/manual/pipeline/filters/grep            |
| Kubernetes      | 레코드에  Kube 의 메타 데이터 추가                             | https://docs.fluentbit.io/manual/pipeline/filters/kubernetes      |
| Lua             | 사용자 지정 Lua (https://www.lua.org/)를 사용하여 수신 레코드를 수정 | https://docs.fluentbit.io/manual/pipeline/filters/lua             |
| Parser          | Paser 를 이용한 레코드 구문 분석                              | https://docs.fluentbit.io/manual/pipeline/filters/parser          |
| Record Modifier | 필드를 추가하거나 특정 필드를 제외                                | https://docs.fluentbit.io/manual/pipeline/filters/record-modifier |
| Rewrite Tag     | 설정된 Tag 를 재구성                                      | https://docs.fluentbit.io/manual/pipeline/filters/rewrite-tag     |
| Standard Output | 입력된 레코드를 Std Out 으로 출력                             | https://docs.fluentbit.io/manual/pipeline/filters/standard-output |
| Throttle        | 데이터 처리 속도 조절                                       | https://docs.fluentbit.io/manual/pipeline/filters/throttle        |
| Nest            | 중첩된 키의 처리                                          | https://docs.fluentbit.io/manual/pipeline/filters/nest            |
| Modify          | 규칙과 조건을 사용하여 레코드를 변경                               | https://docs.fluentbit.io/manual/pipeline/filters/modify          |
| Tensorflow      | 데이터 레코드에 대해 학습 추론 작업 (Tensorflow Lite 엔진)       | https://docs.fluentbit.io/manual/pipeline/filters/tensorflow      |

- Buffer
  - 기본적으로 Fluent Bit는 데이터를 처리 할 때 메모리를 기본 및 임시 장소로 사용하여 레코드를 저장
  - 집계 및 데이터 안전 기능을 제공하기 위해 파일 시스템에 기반한 영구 버퍼링
  - Buffering & Storage (https://docs.fluentbit.io/manual/administration/buffering-and-storage)

- router
  - 필터를 통해 하나 또는 여러 대상으로 데이터를 라우팅
  - 라우터는 **Tag** , **Match** 룰 규칙에 따라 결정
  - 데이터가 Input 플러그인에 의해 생성 될 때 **Tag** 와 함께 제공 (대부분의 경우 **Tag** 가 수동으로 구성됨)
  - **Tag** 는 데이터 소스를 식별하는 데 도움이되는 사람이 읽을 수있는 표시기
  - 데이터가 라우팅되어야하는 위치를 정의하려면 Output 구성에 규칙을 지정
  - 예제 : Elasticsearch 데이터베이스에 CPU 메트릭을 전달

    ```yaml
    [INPUT]
        Name cpu
        Tag  my_cpu

    [INPUT]
        Name mem
        Tag  my_mem

    [OUTPUT]
        Name   es
        Match  my_cpu

    [OUTPUT]
        Name   stdout
        Match  my_mem
    ```
- Routing with Wildcard
  - 라우팅은 일치 패턴에서 와일드 카드를 지원
  - 예제 :  두 데이터 소스의 공통 대상을 정의
    ```yml
    [INPUT]
        Name cpu
        Tag  my_cpu

    [INPUT]
        Name mem
        Tag  my_mem

    [OUTPUT]
        Name   stdout
        Match  my_*
    ```

- Output
  - 데이터를 보낼 대상을 정의

| Module                       | 설명                                                  | 상세                                                                 |
|------------------------------|-----------------------------------------------------|--------------------------------------------------------------------|
| Amazon CloudWatch            | AWS CloudWatch Logs                                 | https://docs.fluentbit.io/manual/pipeline/outputs/cloudwatch       |
| Amazon Kinesis Data Firehose | AWS Kinesis Data Firehose                           | https://docs.fluentbit.io/manual/pipeline/outputs/firehose         |
| Amazon S3                    | AWS S3                                              | https://docs.fluentbit.io/manual/pipeline/outputs/s3               |
| Azure                        | Azure Log Analytics                                 | https://docs.fluentbit.io/manual/pipeline/outputs/azure            |
| Azure Blob                   | Azure Blob Storage                                  | https://docs.fluentbit.io/manual/pipeline/outputs/azure_blob       |
| BigQuery                     | Google Cloud BigQuery service                       | https://docs.fluentbit.io/manual/pipeline/outputs/bigquery         |
| Counter                      | 플러시 시간의 레코드 수                                       | https://docs.fluentbit.io/manual/pipeline/outputs/counter          |
| Datadog                      | Datadog                                             | https://docs.fluentbit.io/manual/pipeline/outputs/datadog          |
| Elasticsearch                | Elasticsearch                                       | https://docs.fluentbit.io/manual/pipeline/outputs/elasticsearch    |
| File                         | File                                                | https://docs.fluentbit.io/manual/pipeline/outputs/file             |
| FlowCounter                  | 프로토콜 의 레코드 수                                        | https://docs.fluentbit.io/manual/pipeline/outputs/flowcounter      |
| Forward                      | peer 간의 데이터 를 포워드                                   | https://docs.fluentbit.io/manual/pipeline/outputs/forward          |
| GELF                         | GELF format 으로 graylog(https://www.graylog.org/) 전송 | https://docs.fluentbit.io/manual/pipeline/outputs/gelf             |
| HTTP                         | HTTP (MessagePack (or JSON) format )                | https://docs.fluentbit.io/manual/pipeline/outputs/http             |
| InfluxDB                     | InfluxDB                                            | https://docs.fluentbit.io/manual/pipeline/outputs/influxdb         |
| Kafka                        | Kafka (librdkafka C library 사용)                     | https://docs.fluentbit.io/manual/pipeline/outputs/kafka            |
| Kafka REST Proxy             | Kafka REST Proxy                                    | https://docs.fluentbit.io/manual/pipeline/outputs/kafka-rest-proxy |
| LogDNA                       | LogDNA(클라우드 기반 로그 관리 시스템)                           | https://docs.fluentbit.io/manual/pipeline/outputs/logdna           |
| Loki                         | Loki                                                | https://docs.fluentbit.io/manual/pipeline/outputs/loki             |
| NATS                         | Network NAT                                         | https://docs.fluentbit.io/manual/pipeline/outputs/nats             |
| New Relic                    | New Relic                                           | https://docs.fluentbit.io/manual/pipeline/outputs/new-relic        |
| NULL                         | NULL                                                | https://docs.fluentbit.io/manual/pipeline/outputs/null             |
| PostgreSQL                   | PostgreSQL                                          | https://docs.fluentbit.io/manual/pipeline/outputs/postgresql       |
| Slack                        | Slack                                               | https://docs.fluentbit.io/manual/pipeline/outputs/slack            |
| Stackdriver                  | Google Cloud Stackdriver Logging                    | https://docs.fluentbit.io/manual/pipeline/outputs/stackdriver      |
| Standard Output              | STD OUT (데이터 포맷 Json)                               | https://docs.fluentbit.io/manual/pipeline/outputs/standard-output  |
| Splunk                       | Splunk                                              | https://docs.fluentbit.io/manual/pipeline/outputs/splunk           |
| Syslog                       | Syslog (데이터 포맷 RFC3164 and RFC5424)                 | https://docs.fluentbit.io/manual/pipeline/outputs/syslog           |
| TCP & TLS                    | TCP                                                 | https://docs.fluentbit.io/manual/pipeline/outputs/tcp-and-tls        |
| Treasure Data                | Treasure Data cloud service.                        | https://docs.fluentbit.io/manual/pipeline/outputs/treasure-data    |

### Fluentbit, Kinesis 구성

- Kinesis DataStream Create

![aws_eks_monitoring_3](/images/aws_eks_monitoring/aws_eks_monitoring_3.png)

- EKS Fluentbit Install

  ```bash
    # kubectl create namespace log-monitor

    # kubectl get namespace
    NAME                   STATUS   AGE
    log-monitor            Active   1m
  ```

- rbac 설정

  ```bash
    # kubectl apply -f ./eks-fluent-bit-daemonset-rbac.yaml

    # kubectl get ClusterRole
    NAME                 AGE
    pod-log-reader       1m
    # kubectl get ClusterRoleBinding
    NAME                 AGE
    pod-log-crb          1m
  ```

- eks-fluent-bit-daemonset-rbac.yaml

  ```yaml
    kind: ClusterRole
    metadata:
      name: pod-log-reader
    rules:
    - apiGroups: [""]
      resources:
      - namespaces
      - pods
      verbs: ["get", "list", "watch"]
    ---
    apiVersion: rbac.authorization.k8s.io/v1beta1
    kind: ClusterRoleBinding
    metadata:
      name: pod-log-crb
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: pod-log-reader
    subjects:
    - kind: ServiceAccount
      name: fluent-bit
      namespace: log-monitor
  ```

- Configmap 생성

  ```bash
    # kubectl apply -f ./eks-fluent-bit-configmap.yaml

    # kubectl get configmap -n log-monitor
    NAME                DATA   AGE
    fluent-bit-config   2      1m
  ```

- eks-fluent-bit-configmap.yaml
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluent-bit-config
  namespace: log-monitor
  labels:
    app.kubernetes.io/name: fluentbit
data:
  fluent-bit.conf: |
    [SERVICE]
        Parsers_File  parsers.conf
        Flush        10
        Daemon       Off
        Log_Level    debug
    [INPUT]
        Name              tail
        Tag               test.access
        Path              /var/lib/docker/overlay2/*/merged/webapp/logs/access.log
        Parser            accesslog
        DB                /var/log/flb_accesslog.db
        Mem_Buf_Limit     5MB
        Skip_Long_Lines   On
        Refresh_Interval  10

    [INPUT]
        Name              tail
        Tag               test.api-responselog
        Path              /var/lib/docker/overlay2/*/merged/webapp/logs/api-response*.log
        Parser            api-responselog
        DB                /var/log/flb_api-responselog.db
        Mem_Buf_Limit     5MB
        Skip_Long_Lines   On
        Refresh_Interval  10

    [INPUT]
        Name              tail
        Tag               test.api-requestlog
        Path              /var/lib/docker/overlay2/*/merged/webapp/logs/api-request*.log
        Parser            api-requestlog
        DB                /var/log/flb_api-requestlog.db
        Mem_Buf_Limit     5MB
        Skip_Long_Lines   On
        Refresh_Interval  10

    [FILTER]
        Name parser
        Match test.access
        key_name log
        Parser accesslog

    [FILTER]
        Name parser
        Match test.api-responselog
        key_name log
        Parser api-responselog

    [FILTER]
        Name parser
        Match test.api-requestlog
        key_name log
        Parser api-requestlog

    [FILTER]
        Name modify
        Match test.access
        Add logtype accesslog

    [FILTER]
        Name modify
        Match test.api-responselog
        Add logtype api-responselog

    [FILTER]
        Name modify
        Match test.api-requestlog
        Add logtype api-requestlog

    [FILTER]
        Name aws
        Match *
        imds_version v1
        az true
        ec2_instance_id true
        ec2_instance_type true
        private_ip true
        ami_id true
        account_id true
        hostname true
        vpc_id true

    [OUTPUT]
        Name kinesis
        Match **
        region ap-northeast-2
        stream infra-dev-kinesis-01
        partition_key container_id
        aws_key_id AK***********************
        aws_sec_key 56****************************************
        ##compression zlib   # Logstash 에서 데이터 decompress 불가로 옵션 제외
        append_newline true
  parsers.conf: |
    [PARSER]
        Name   accesslog
        Format regex
        Regex ^(?<remote>[^ ]*) (?<host>[^ ]*) (?<user>[^ ]*) \[(?<time>[^\]]*)\] "(?<method>\S+)(?: +(?<path>[^\"]*?)(?: +\S*)?)?" (?<code>[^ ]*) (?<size>[^ ]*) "(?<referer>[^ ]*)" "(?<agent>[^\"]*)"
        Time_Key time
        #Time_Format  %Y-%m-%dT%H:%M:%S%z
        Time_Format %d/%b/%Y:%H:%M:%S %z
        Time_Keep    On
        # Command       | Decoder   | Field | Optional Action   |
        # ==============|===========|=======|===================|
        #Decode_Field_As   json        log
        Decode_Field_As   escaped      log

    [PARSER]
        Name   api-responselog
        Format regex
        Regex ^\[(?<time>[^\]]*)\] (?<code>\S+) (?<result>\S+) (?<path>[^ ]*) (?<logdata>.*)$
        Time_Key time
        Time_Format  %Y-%m-%d %H:%M:%S GMT%z (GMT)
        Time_Keep    On
        # Command       | Decoder   | Field | Optional Action   |
        # ==============|===========|=======|===================|
        #Decode_Field_As   json        log
        Decode_Field_As   escaped      log

    [PARSER]
        Name   api-requestlog
        Format regex
        Regex ^\[(?<time>[^\]]*)\] (?<method>\S+) (?<path>[^ ]*) (?<logdata>.*)$
        Time_Key time
        Time_Format  %Y-%m-%d %H:%M:%S GMT%z (GMT)
        Time_Keep    On
        # Command       | Decoder   | Field | Optional Action   |
        # ==============|===========|=======|===================|
        #Decode_Field_As   json        log
        Decode_Field_As   escaped      log
```

**- Pod 내 디렉토리 로그 시에 fluetbit daemon set 생성시 "/var/lib/docker/overlay2" 볼륨 마운트 필요**
**- stdout 일경우 /var/lib/docker/containers 에서 파일 생성됨**

- Daemon Set 생성

  ```bash
    # kubectl apply -f ./eks-fluent-bit-daemonset.yaml

    # kubectl get damonset -n log-monitor
    NAME        DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
    fluentbit   2         2         2       2            2           <none>          3d21h
  ```
- eks-fluent-bit-daemonset.yaml

  ```bash
    apiVersion: apps/v1
    kind: DaemonSet
    metadata:
      name: fluentbit
      namespace: log-monitor
      labels:
        app.kubernetes.io/name: fluentbit
    spec:
      selector:
        matchLabels:
          name: fluentbit
      template:
        metadata:
          labels:
            name: fluentbit
        spec:
          serviceAccountName: fluent-bit
          containers:
          - name: aws-for-fluent-bit
            image: amazon/aws-for-fluent-bit:latest
            securityContext:
              runAsNonRoot: false
              runAsUser: 0
              readOnlyRootFilesystem: true
            volumeMounts:
            - name: varlog
              mountPath: /var/log
            - name: varlibdockercontainers
              mountPath: /var/lib/docker/containers
              readOnly: true
            - name: podmonitor
              mountPath: /var/lib/docker/overlay2
              readOnly: true
            - name: fluent-bit-config
              mountPath: /fluent-bit/etc/
            - name: mnt
              mountPath: /mnt
              readOnly: true
            resources:
              limits:
                cpu: 500m
                memory: 100Mi
              requests:
                cpu: 100m
                memory: 50Mi
          volumes:
          - name: varlog
            hostPath:
              path: /var/log
          - name: varlibdockercontainers
            hostPath:
              path: /var/lib/docker/containers
          - name: podmonitor
            hostPath:
              path: /var/lib/docker/overlay2
          - name: fluent-bit-config
            configMap:
              name: fluent-bit-config
          - name: mnt
            hostPath:/mnt
  ```

- pod 생성 확인
  ```bash
    # kubectl get pods -n log-monitor
    NAME              READY   STATUS    RESTARTS   AGE
    fluentbit-66cbs   1/1     Running   0          27h
    fluentbit-bp6kj   1/1     Running   0          27h
  ```

- fluentbit Log 확인
```bash
# kubectl logs fluentbit-66cbs -n log-monitor
[2020/10/20 03:56:08] [debug] [input:tail:tail.2] scanning path /var/lib/docker/overlay2/*/merged/webapp/logs/api-request*.log
[2020/10/20 03:56:08] [debug] [input:tail:tail.0] scanning path /var/lib/docker/overlay2/*/merged/webapp/logs/access.log
[2020/10/20 03:56:08] [debug] [input:tail:tail.1] scanning path /var/lib/docker/overlay2/*/merged/webapp/logs/api-response*.log
```

### ElasticStack 구성

- Elasticsearh & Kibana 구성
- Single Node 구성
  - docker-compose.yml
  ```yaml
    version: '3.8'
    services:
      elasticsearch:
        container_name: awslog-elasticsearch
        image: docker.elastic.co/elasticsearch/elasticsearch:7.9.2
        environment:
          - node.name=awslog-elasticsearch
          - cluster.name=awslog-total
          - discovery.type=single-node
          - bootstrap.memory_lock=true
          - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
        ulimits:
          memlock:
            soft: -1
            hard: -1
        volumes:
          - /data/es_data01:/usr/share/elasticsearch/data
        ports:
          - 9200:9200
        networks:
          - elastic

      kibana:
        image: docker.elastic.co/kibana/kibana:7.9.2
        container_name: awslog-kibana
        environment:
          ELASTICSEARCH_URL: http://awslog-elasticsearch:9200
          ELASTICSEARCH_HOSTS: http://awslog-elasticsearch:9200
        ports:
          - 5601:5601
        networks:
          - elastic
    networks:
      elastic:
        driver: bridge
  ```

  - Logstash 구성
    - tar 파일
    ```bash
    # wget https://artifacts.elastic.co/downloads/logstash/logstash-7.9.2.tar.gz
    # tar xvf logstash-7.9.2.tar.gz
    ```
    - kinesis plugin install

      ```bash
        # bin/logstash-plugin install logstash-input-kinesis

        # bin/logstash-plugin list | grep kinesis
        logstash-input-kinesis
      ```
  - logstash config 설정
  ```json
    input {
      kinesis {
        kinesis_stream_name => "infra-dev-kinesis-01"
        region => "ap-northeast-2"
        codec => json { }
        #type => kinesis
      }
    }

    filter {

      if ( [logtype] in "accesslog" ) {

          mutate {
            convert => {
              "code" => "integer"
              "size" => "integer"
            }
          }

          geoip {
          source => "remote"
          target => "remote_geoip"
          }

          geoip {
          source => "remote"
          target => "remote_geoip_asn"
          database => "/usr/share/logstash-7.9.2/vendor/bundle/jruby/2.5.0/gems/logstash-filter-geoip-6.0.3-java/vendor/GeoLite2-ASN.mmdb"
          }
        }
      else if ( [logtype] in "api-responselog" ) {

          json {
            source => "logdata"
          }
      }
    }

    output {

      if ( [logtype] in "accesslog" ) {
        elasticsearch
        {
          hosts => ["localhost:9200"]
          index => "accesslog-%{+YYYYMM}"
        }

        s3 {
          access_key_id => "AK***************"
          secret_access_key => "56************************"
          region => "ap-northeast-2"
          bucket => "test-accesslog"
          codec => json_lines
          canned_acl => "private"
          temporary_directory => "/opt/logstash/S3_temp/"
          #size_file => 1024000
          time_file => 5
          prefix => "test-accesslog/%{+YYYY}/%{+MM}/%{+dd}/"
        }
      }
    else if ( [logtype] in "api-responselog" ) {
        elasticsearch
        {
          hosts => ["localhost:9200"]
          index => "api-responselog-%{+YYYYMM}"
        }
      }
    else if ( [logtype] in "api-requestlog" ) {
        elasticsearch
        {
          hosts => ["localhost:9200"]
          index => "api-requestlog-%{+YYYYMM}"
        }
      }

    }
  ```

- logstash Start
  ```bash
  # bin/logstash -f conf.d/test-api-log_kinesis.conf
  ```