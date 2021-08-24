---
title: Elasticsearch Warm Node

toc: true
toc_sticky: true

categories:
  - devops  
tags:
  - elastic
---

# 운영중인 Elasticsearch Cluster 내에 Online Warm Node 추가

  - Elasticsearch 3대에 Warm Node 3대 Online 추가
    ![warm_1](/images/ElasticsearchWarm/warm_1.png)

  - 적용 버전 : 7.4.2 / 7.5.2

#### 1. 운영 중인 Elasticsearch master node를 Hot Node 지정

  - Elasticsearch Shard 할당 비할성화
    ```java
      # PUT _cluster/settings
        {
          "persistent": {
          "cluster.routing.allocation.enable": "primaries"
          }
        }

      # POST _flush/synced
    ```

  - Elasticsearch Config 내 Hot Node 추가
    ```bash
      # vi /etc/elasticsearch/elasticsearch.yml 
          node.attr.log: "hot"
    ```

  - Elasticsearch 서비스 재기동
    ```bash
      # systemctl stop elasticsearch
      # systemctl start elasticsearch
    ```

  - Elasticsearch Shard 할당 비할성화
    ```java
      # PUT _cluster/settings
          {
            "persistent": {
            "cluster.routing.allocation.enable": null
            }
          }
    ```

  - Elasticsearch 3대 위 반복 적용
    - Elasticsearch rolling upgrade 와 동일

#### 2. Hot node 미 설정된 index를 hot node 정의
  - Elasticsearch 내 Index 를 Hot Node 로 설정
  - 미설정시 Warm Node 추가 후 Shard Rebalancing 되는 문제 발생
  - Index 전체 적용
    ```bash
      # vi index_hotnode_setting.sh
      
        ALL_INDEX=`curl http://localhost:9200/_cat/indices | grep open awk '{print $2 }'`

        ## 적용
        for INDEX in $ALL_INDEX
        do
        
          curl -H 'Content-Type: application/json' -XPUT http://localhost:9200/${INDEX}/_settings -d '
          {
            "index.routing.allocation.require.log": "hot"
          }'
        done

        ## 확인
        for INDEX in $ALL_INDEX
        do

          curl -H 'Content-Type: application/json' -XGET http://localhost:9200/${INDEX}/_settings

        done
    ```
  - Index Setting 내 Hot Node 정보 확인
    ![warm_2](/images/ElasticsearchWarm/warm_2.png)

  - ILM 설정된 Index 의 경우 Setting 추가 설정
    - 미 설정시 ILM 설정된 Index 의 신규 생성 시 Hot node 지정 안됨
    - Kibana -> Index Mnagement -> 선택 및 Edit -> Setting 내 추가 및 저장
    ```java 
      index.routing.allocation.require.log: "hot"
    ```

#### 3. Warm Node 설정 및 Cluster 추가
  - Elasticsearch 설치는 기존 Cluster 내 Node 와 동일 하게 설치
  - Elasticsearch Config 내 Warm Node 추가
    ```bash
      # vi /etc/elasticsearch/elasticsearch.yml 
          node.attr.log: "warm"
    ```
  - Elasticsearch 서비스 기동
    ```bash
      # systemctl start elasticsearch
    ```
  - 추가 된 Node 확인
    ```java
      # GET _cat/nodeattrs?v
        node           host    ip         attr           value
        warmserver1  1.1.1.1 1.1.1.1 ml.machine_memory 3973320704
        warmserver1  1.1.1.1 1.1.1.1 xpack.installed   true
        warmserver1  1.1.1.1 1.1.1.1 ml.max_open_jobs  20
        warmserver1  1.1.1.1 1.1.1.1 log               warm         <- Warm 노드 확인
        warmserver2  1.1.1.2 1.1.1.2 ml.machine_memory 3973320704
        warmserver2  1.1.1.2 1.1.1.2 xpack.installed   true
        warmserver2  1.1.1.2 1.1.1.2 ml.max_open_jobs  20
        warmserver2  1.1.1.2 1.1.1.2 log               warm         <- Warm 노드 확인
        warmserver3  1.1.1.3 1.1.1.3 ml.machine_memory 3973320704
        warmserver3  1.1.1.3 1.1.1.3 xpack.installed   true
        warmserver3  1.1.1.3 1.1.1.3 ml.max_open_jobs  20
        warmserver3  1.1.1.3 1.1.1.3 log               warm         <- Warm 노드 확인
    ```
    ![warm_3](/images/ElasticsearchWarm/warm_3.png)

#### 4. Index Warm Node 이전 방법
  - ILM 설정된 Index
    - Kibana -> Index Lifecycle Policies -> 적용 ILM 선택 -> Warm phase -> Activate warm phase Enable
      - Timing for warm phase : 30 # 생성된지 30일 지난 Index
      - Select a node attribute to control shard allocation : log:warm(3) # 옮길 Warm Node 

      ![warm_4](/images/ElasticsearchWarm/warm_4.png)
  - ILM 미설정된 Index
    ```java
      curl -H 'Content-Type: application/json' -XPUT http://localhost:9200/${INDEX}/_settings -d '
        {
          "index.routing.allocation.require.log": "warm"
        }'
    ```
    - @timestamp 기준 30일전 Index Warm Node 이전 script
      ```bash
        #!/bin/sh

        now=$(date | cut -d' ' -f 4)
        time_now=$(date -u -d "$now" +"%s")

        INDEX_ALL=`curl -H 'Content-Type: application/json' http://localhost:9200/_cat/indices | awk '{print $3 }' | grep -v ^"\."`

        for INDEX in $INDEX_ALL
        do
          timestamp=`curl -H 'Content-Type: application/json' http://localhost:9200/${INDEX}/_search?pretty -d '
          {
              "size": 1,
              "sort": { "@timestamp" : "desc" }
          }' | jq '.hits.hits[]._source."@timestamp"' | sed 's/\"//g'`

          index_time=$(date -u -d "$timestamp" +"%s")
          difference=$(echo $((time_now - index_times)))

          if [ $difference -ge 2592000 ]
          then
            echo "Time difference is greater than 30 days"
            curl -H 'Content-Type: application/json' -XPUT http://localhost:9200/${INDEX}/_settings -d '
            {
              "index.routing.allocation.require.log": "warm"
            }'
          else
            echo "Time difference is less than 30 days"
          fi
        done
      ```