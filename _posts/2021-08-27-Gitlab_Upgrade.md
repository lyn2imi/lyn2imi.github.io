---
title: Gitlab Version Upgrade 및 Docker 이전

toc: true
toc_sticky: true

categories:
  - devops  
tags:
  - Gitlab
---

# [Gitlab] 최신 버전 업그레이드


### 11.1.0 -> 12.10.3 업그레이드 및 Docker 이전
- Gitlab Version
```
현재 버전 : 11.1.0
최신 버전 : 12.10.3
```

- 기존 Data Backup
```bash
# gitlab-rake gitlab:backup:create
# ls -l /var/opt/gitlab/backups/
-rw------- 1 git git 1626449920  2월  5 16:37 1580888226_2020_02_05_11.1.0_gitlab_backup.tar
```

- 12.10.3 버전 Gitlab 구성 (/w Docker-compose)
  - Restore 시 동일 버전으로 설치 필요
    ```yaml
    web:
    image: 'gitlab/gitlab-ce:11.1.0 -ce.0'
    restart: always
    ports:
        - '80:80'
    volumes:
        - '/root/gitlab_docker/data/gitlab/config:/etc/gitlab'
        - '/root/gitlab_docker/data/gitlab/logs:/var/log/gitlab'
        - '/root/gitlab_docker/data/gitlab/data:/var/opt/gitlab'
    ```
  - Gitlab Start 
    ```bash
    # docker-compose up -d
    ```

- Gitlab Restore
  ```bash
    # mv 1580888226_2020_02_05_11.1.0_gitlab_backup.tar /root/gitlab_docker/data/gitlab/data/
    # docker-compose exec web gitlab-rake gitlab:backup:restore BACKUP=1580888226_2020_02_05_11.1.0
  ```

- 단계적 gitlab Upgrade
  - Upgrade Version : 11.1.0 -> 11.3.4 -> 11.11.8 -> 12.0.0 -> 12.10.3
    ```bash
        # docker-compose stop
        # vi docker-compose.yml
    ```
  - 아래 내용 만 version 에 따라 변경 후 Up/Down 진행
    ```bash
    image: 'gitlab/gitlab-ce:11.1.0 -ce.0'
    image: 'gitlab/gitlab-ce:11.3.4 -ce.0'
    image: 'gitlab/gitlab-ce:11.11.8 -ce.0'
    image: 'gitlab/gitlab-ce:12.0.0 -ce.0'
    image: 'gitlab/gitlab-ce:12.10.3 -ce.0'
    # docker-compose up -d
    ```
  - 기존 Docker 삭제
    ```bash  
        # docker images
        # docker rmi <IMAGE ID>
    ```
- 11.1.0 -> 12.10.3 업그레이드 이슈
  - 첨부파일 다운로드 불가 오류
  - 외부 디렉토리 의 data/gitlab-rails/uploads 디렉토리 내 권한을 700 으로 변경시 확인 가능
  ```bash
    # cd /root/gitlab_docker/data/gitlab/data/gitlab-rails/uploads
    # find ./ -type d | xargs chmod +rwx
    # find ./ -type f | xargs chmod +rw
  ```

### 12.10.3 -> 13.8.3 업그레이드

- Gitlab Version
```
현재 버전 : 12.10.3
최신 버전 : 13.8.3
```
- 현재버전 gitlab 백업
  - 최종 백업 파일 생성
  ```bash
    # gitlab-rake gitlab:backup:create
  ```
  - gitlab-secrets.json 파일 백업 (버전 업그레이드 오류에 따른 조치, 아래 이슈 참고)
  ```bash
    # cp /gitlab/config/gitlab-secrets.json /gitlab-secrets.json_backup
  ```

- 단계적 gitlab Upgrade
  - Upgrade Version : 12.10.3 -> 12.10.14 -> 13.0.14 -> 13.1.11 -> 13.8.3
    ```bash
        # docker-compose stop
        # vi docker-compose.yml
    ```
  - 아래 내용 만 version 에 따라 변경 후 Up/Down 진행
    ```bash
    image: gitlab/gitlab-ce:12.10.14-ce.0
    image: gitlab/gitlab-ce:13.0.14-ce.0
    image: gitlab/gitlab-ce:13.1.11-ce.0
    image: gitlab/gitlab-ce:13.8.3-ce.0

    # docker-compose up -d
    ```

  - 기존 Docker 삭제
    ```bash  
        # docker images
        # docker rmi <IMAGE ID>
    ```
  - gitlab-secrets.json 파일 복구
    ```bash
      # cp /gitlab-secrets.json_backup /gitlab/config/gitlab-secrets.json
    ```
- 12.10.3 -> 13.8.3 업그레이드 이슈
  - gitlab-cicd runnner 설정 페이지 500 / gitlab-cicd 변수 로딩 에러
    - gitlab의 토큰 및 암호화 키 불일치로 발생는 이슈로 gitlab-secrets.json을 기존과 동일하게 셋팅하는 것으로 해결 가능

- Rolling Upgrade 참고 URL : [https://docs.gitlab.com/ee/update/](https://docs.gitlab.com/ee/update/)