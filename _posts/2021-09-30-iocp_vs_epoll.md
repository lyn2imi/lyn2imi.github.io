---
title: Windows IOCP VS Linux Epoll

toc: true
toc_sticky: true

categories:
  - devops
tags:
  - os
---

# Windows IOCP / Linux Epoll

 - 운영체제 레벨에서 지원하는 멀티 플렉싱 모델
 - 각 OS 에서 I/O 를 처리하는 방식 을 정의하고 차이점을 비교

## IOCP

  - IOCP 란
    - Overlapped I/O 확장 모델
    - 여러 동시 비동기 I/O 작업 을 수행 하기 위한 API
    - 입력/출력 완료 포트 개체가 생성되고 다수의 소켓 또는 파일 핸들 과 연결
    - 논블로킹 프로세스로서 최소한의 스레드를 사용해서 Port와 관련된 I/O 처리하는 기법
    - 커널영역과 유저영역의 버퍼를 공유

  - IOCP 장점
    - 적은 수의 스레드만을 사용
    - 적은 수의 스레드 사용으로 CPU점유율도 낮으며, 작은 비용의 Context switching
    - winsock2 API중 가장 뛰어난 확장성과 성능

  - IOCP 단점
    - 복잡한 프로그램 구현
    - Windows 기반 플랫폼에서만 사용 가능
    - 하나의 I/O operation 마다 버퍼영역에 대한 page-lock/unlock이 필요
    - 하나의 I/O operation 마다 시스템 콜을 호출

## Epoll
  
  - Epoll 이란
    - 이벤트 통지(Event Notification) 입출력 처리
    - select의 단점을 보완하여 사용할 수 있도록 만든 I/O 통지 모델
    - 리눅스 커널 시스템 호출 확장 I/O 이벤트 알림 메커니즘

  - Epoll 잠점
    - 상태변화의 확인을 위한, 전체 파일 디스크립터를 대상으로 하는 반복문의 불필요
    - select 함수에 대응하는 epoll_wait 함수 호출시, 매번 전달되는 관찰 대상의 정보 불필요

  - Epoll 단점
    - Linux외 다른 유닉스에서 사용 불가(이식성이 좋지 않음)


#### IOCP Epoll 차이점
  ```
  - IOCP는 epoll과는 달리 유저 영역으로 직접 데이터를 가져오는 zero copy가 가능하다고 한다. 
    그렇지만 zero copy는 작은 패킷이 왔다 갔다하는 상황에서는 성능 저하와는 별 상관이 없고, 
    더 중요한건 context switching 오버헤드라고 한다.

  - Linux epoll 의 경우 커널 영역의 데이터 스트림을 유저영역으로 복사하는 만큼 지연
    IOCP 는 이벤트를 받아 이벤트 루틴이 깨어날 때 이미 데이터 스트림이 유저 영역에 있어 바로 작업 쓰레드로 넘겨 지연 없이 다음 이벤트를 기다릴 수 있음
  ```


**출처**
- https://its-fusion-blog.tistory.com/18
- https://www.slideshare.net/sm9kr/iocp-vs-epoll-perfor