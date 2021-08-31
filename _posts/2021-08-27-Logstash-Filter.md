---
title: Logstash 기능 테스트 모음

toc: true
toc_sticky: true

categories:
  - devops  
tags:
  - elastic
  - logstash
  - ruby
---
- Last Update : 2021-08-27

# Logstash Input 기능 테스트 한 내용 모음

# Logstash Filter 기능 테스트 한 내용 모음

#### Ruby 를 이용한 파일 내 필드 와 일치 여부 판단 방법
  - 매치 파일 생성
  ```bash
    # cat test.txt
    aaaa
    bbbb
    cccc
  ```
  - Filter 정보
  ```json
      ruby {
        code => '
        eventName = event.get("eventfilter")        
        if File.read("/test.txt").include? eventfilter
          event.set("event_add", "eventok")
        end
        '
    }
  ```


# Logstash Ouput 기능 테스트 한 내용 모음
