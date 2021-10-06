---
title: 페이스북 의 장애 원인으로 떠 오르는 BGP 란?

toc: true
toc_sticky: true

categories:
  - devops
tags:
  - issue
  - network
---

# 페이스북 장애?
  - 페이스북 과 계열 서비스인 인스타그램 , 왓츠맨 등 4일 동부 시간 11시 40분 부터 약 7 시간 동안 장애 발생
  - 정확한 장애 원인은 공식적으로 발표 되지 않고 있음
  - 일부 사이트에서는(블라인드 등..) 사원증 테그 오류 및 원격 접속 등으로 장애 지연 발생
  - 공식적인 발표는 없으나, BGP 오류로 인한 장애로 지목 되고 있음
  - 관련 기사 : 
    - https://m.khan.co.kr/world/world-general/article/202110051016001#c2b
    - http://it.chosun.com/site/data/html_dir/2021/10/06/2021100601589.html

### 장애 원인으로 지목된 BGP 란?

  - BGP(Border Gateway Protocol) ?
    - 내비게이션을 통하여 도착 지점의 최적의 경로를 찾듯 지속적으로 업데이트되는 내비게이션과 같음
    - 서로다른 AS(autonomous system) 사이에서 사용 되는 라우팅 프로토콜
    - 대륙 또는 기업/ISP 간 AS 의 라우팅 정보를 교환하는 데 사용
    - TCP 포트 179번 사용, 유니캐스트 방식으로 교환
    ```
    AS 란 : 
      - 독립적으로 운영(ISP 같은..) 하는 네트워크 
      - IRP(Interior Router Protocol) : AS 내에 라우터들 간의 라우팅 정보 교환을 위한 프로토콜 
      - ERP(Exterior Router Protocol) : 다른 AS에 속하는  라우터들  간에  라우팅  정보  교환을 위한 프로토콜
    ```

  - BGP Peer 종류
    - eBGP(external BGP) : 서로 다른 AS 사이에서 BGP를 구성하는 경우
    - iBPG(internal BGP) : 동일 AS 안에서 BPG를 구성하는 경우

### BGP 문제가 장애의 원인이 맞는가?
  - 글로벌 장애로 내/외부 접속 불가 사태로 보았을때 네트워크 문제일 가능성이 큼
  - BGP 공유는 각 기업/ISP 등의 설정 방식에 따라 다르며, 복구 시간이 긴 것도 같은 원인일 듯
  - 일부 접속 가능 한 **지역** 이 있는 것으로 봐서 BGP 정보가 업데이트 전이거나 빠르게 정삭적인 BGP 정보가 업데이트 되지 않았을까? 추측

### 페이스북 공식 장애 원인
  - 현재(2021/10/07) 까지는 공식 장애를 발표 하고 있지 않으며, 공식 발표시 업데이터 예정

**참고 URL : https://www.itworld.co.kr/t/62078/%EB%84%A4%ED%8A%B8%EC%9B%8C%ED%81%AC/181614**
