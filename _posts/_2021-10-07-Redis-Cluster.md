---
title: Redis Cluster 구성

toc: true
toc_sticky: true

categories:
  - devops
tags:
  - Redis
---

# Redis

### Redis 란?

  - 메모리 기반의 Key,Value 구조 데이터 관리 시스템
  - 모든 데이터를 메모리에 저장하고 조회하기에 빠른 Read, Write 속도를 보장하는 비 관계형 데이터베이스

### Redis 의 데이터 타입

  - String : 일반적인 형태로, key - value 로 저장하는 형태
  - Lists: 삽입 순서에 따라 정렬된 문자열의 집합. 기본적인 linked list 형태
  - Sets: 고유하고 정렬되지 않은 문자열의 집합(중복된 데이터를 여러번 저장하면 최종 한번만 저장)
  - Sorted Sets: 
    - Sets와 비슷하지만 모든 값은 스코어로 정렬됨
    - Sets와 달리 다양한 방법으로 활용 가능 (ex. 상위10개의 값, 하위 10개의 값)
  - Hashes: value와 연관된 필드로 구성된 맵. 모든 필드와 값은 모두 문자열로 구성
  - Bit arrays (Bitmaps) : bit array를 다를 수 있는 자료구조
  - HyperLogLogs: 집합의 카디널리티를 추정하기 위해 사용되는 확률적 데이터 구조.
  - Streams: 추상 로그 데이터 유형을 제공하는 append-only 자료구조

### Redis Sentinel 과 Cluster 차이

  - Sentinel(https://redis.io/topics/sentinel)
    - Redis 의 고가용성(High Availability) 제공
    - Redis 와 별도 프로세스로 동작
    - Redis Sentinel의 안정적인 릴리스는 Redis 2.8부터 제공
    - 최소 3개의 Sentinel 구성
    - Master / Slave 구조로 Master 노드에 문제 발생시 Slave 노드가 Master 승격 됨
    - Master 의 다운 에 따른 Mater 선출 여부는 N/2 +1 동의 따름

  - Cluster(https://redis.io/topics/cluster-tutorial)
    - 여러 노드에 자동으로 데이터를 Sharding (특정데이터에 집중되는 트레픽을 서버가 나누어 처리)
    - 최대 1000개 노드의 고성능 및 선형 확장성. 
    - 프록시가 없고 비동기 Replication이 사용되며 값에 대해 병합 작업이 수행되지 않음


# Cluster 구성(/w docker-compose)

### Master 노드 구성

  - 3 Master Node docker-compose.yaml

    ```yaml
        version: '3'
        services:
        redis-master:
            container_name: redis-master
            image: redis:6.2.3
            network_mode: "host"
            command: redis-server /etc/redis.conf
            volumes:
            - ./redis.conf:/etc/redis.conf
            restart: always
            ports:
            - 7001:7001
            - 17001:17001
    ```
  - 3 Master Node Config

    ```bash
      # vi redis.conf
        port 7001
        cluster-enabled yes
        cluster-config-file nodes.conf
        cluster-node-timeout 3000
        appendonly yes
    ```
  - 3 Master Node Start

    ```bash
      # docker-compose up -d
    ```

### Node Cluster 구성

  - Cluster 생성

    ```bash
        # docker-compose exec  redis-master redis-cli --cluster create 1.1.1.1:7001 1.1.1.2:7001 1.1.1.3:7001
            >>> Performing hash slots allocation on 3 nodes...
            Master[0] -> Slots 0 - 5460
            Master[1] -> Slots 5461 - 10922
            Master[2] -> Slots 10923 - 16383
            M: 23b96537982c2bd4bb669a1af769b58689de89ca 1.1.1.1:7001
            slots:[0-5460] (5461 slots) master
            M: c4acd3cf9ca75b990269e690693b0b41bf87479e 1.1.1.2:7001
            slots:[5461-10922] (5462 slots) master
            M: 80316aad8bddf757eac79c74fcddf00fdba7b5cf 1.1.1.3:7001
            slots:[10923-16383] (5461 slots) master
            Can I set the above configuration? (type 'yes' to accept): yes
            >>> Nodes configuration updated
            >>> Assign a different config epoch to each node
            >>> Sending CLUSTER MEET messages to join the cluster
            Waiting for the cluster to join

            >>> Performing Cluster Check (using node 1.1.1.1:7001)
            M: 23b96537982c2bd4bb669a1af769b58689de89ca 1.1.1.1:7001
            slots:[0-5460] (5461 slots) master
            M: c4acd3cf9ca75b990269e690693b0b41bf87479e 1.1.1.2:7001
            slots:[5461-10922] (5462 slots) master
            M: 80316aad8bddf757eac79c74fcddf00fdba7b5cf 1.1.1.3:7001
            slots:[10923-16383] (5461 slots) master
            [OK] All nodes agree about slots configuration.
            >>> Check for open slots...
            >>> Check slots coverage...
            [OK] All 16384 slots covered.
    ```

  - Cluster 확인
    ```bash
        #docker-compose exec  redis-master redis-cli -c -p 7001
            127.0.0.1:7001> cluster info
            cluster_state:ok
            cluster_slots_assigned:16384
            cluster_slots_ok:16384
            cluster_slots_pfail:0
            cluster_slots_fail:0
            cluster_known_nodes:3
            cluster_size:3
            cluster_current_epoch:3
            cluster_my_epoch:1
            cluster_stats_messages_ping_sent:78
            cluster_stats_messages_pong_sent:80
            cluster_stats_messages_sent:158
            cluster_stats_messages_ping_received:78
            cluster_stats_messages_pong_received:78
            cluster_stats_messages_meet_received:2
            cluster_stats_messages_received:158
    ```

  - Cluster 데이터 확인
    - 1.1.1.3 노드에서 set
      ```bash
        127.0.0.1:7001> set a 1
        -> Redirected to slot [15495] located at 1.1.1.3:7001
        OK
      ```
    - 1.1.1.1 노드에서 get
      ```bash
        127.0.0.1:7001> get a
        -> Redirected to slot [15495] located at 1.1.1.3:7001
        "1"
      ```


#### redis.conf 정보


loadmodule /path/to/my_module.so # 모듈 로드
bind 127.0.0.1 # 내/외부 접근 IP, IPRange(불필요시 또는 전체 허용시 주석 처리)
protected-mode yes # 보안 설정
  ```
    - Yes이고 bind가 지정되어 있으면 지정한 IP로만 접속할 수 있다.
    - Yes이고 bind가 지정되지 않았으면(comment) 127.0.0.1 (local)만 접속할 수 있다.
    - No이고 bind가 지정되어 있으면 지정한 IP만 접속할 수 있다.
    - No이고 bind가 지정되지 않았으면(comment) 모든 IP로 접속할 수 있다.
  ```
port 6379 # LISTEN TCP 포트 (Default 6379)
tcp-backlog # backlog 큐 사이즈 설정

  ```
    - SNY+ACK 보낼때 Backlog 큐에 저장 되었다가
    - ACK 올때 Backlog 큐에서 제거 됩니다.
    * 레디스의 backlog 크기는 syn_backlog , somaxconn 설정값을 넘을수 없음 
    - 아래 Kernel 값도 변경 필요
      net.core.somaxconn / net.ipv4.tcp_max_syn_backlog
  ```
timeout 0 # 연결 닫기 전 유휴 상태 시간(초)
tcp-keepalive 300 # 클라이언트 종료시 keepalive 시간(초) (timeout 0 일때 만 사용)
daemonize no # 프로세스 데몬(Back bround) 실행 여부


**-참고 URL : http://redisgate.kr/redis/cluster/cluster_start.php**