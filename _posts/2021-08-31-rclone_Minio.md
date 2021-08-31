---
title: rclone 을 통한 Minio 데이터 백업

toc: true
toc_sticky: true

categories:
  - devops  
tags:
  - rclone
  - Minio
---

# rclone Command 를 이용한 파일 백업 
  - 구글의 Go 언어로 만든 클라우드 스토리지 특화 업로드/다운로드 프로그램
  -
  - MC (Minio Client) 보다 많은 옵션(트래픽 제어 등)과 많은 Object Storage 지원함

#### rclone 설치

  ```bash
    # curl https://rclone.org/install.sh | sudo bash

    # which rclone
    /usr/bin/rclone
  ```

  - Default Config 위치 : /root/.config/rclone/

#### minio config 설정

- Config 생성

  ```bash
    # vi /root/.config/rclone/rclone.conf

    [minio]
    type = s3
    provider = Minio
    env_auth = false
    access_key_id = minio
    secret_access_key = minio1234
    endpoint = http://1.1.1.1:9000
    location_constraint =
  ```
- Config 생성 (/w Command Line)
  ```bash
    # rclone config
    Current remotes:

    Name                 Type
    ====                 ====

    e) Edit existing remote
    n) New remote
    d) Delete remote
    r) Rename remote
    c) Copy remote
    s) Set configuration password
    q) Quit config
    e/n/d/r/c/s/q> n
    name> minio
    Type of storage to configure.
    Enter a string value. Press Enter for the default ("").
    Choose a number from below, or type in your own value
     1 / 1Fichier
       \ "fichier"
     2 / Alias for an existing remote
       \ "alias"
     3 / Amazon Drive
    --- 생략 ---
    Storage> s3
    ** See help for s3 backend at: https://rclone.org/s3/ **

    Choose your S3 provider.
    Enter a string value. Press Enter for the default ("").
    Choose a number from below, or type in your own value
     1 / Amazon Web Services (AWS) S3
       \ "AWS"
     2 / Alibaba Cloud Object Storage System (OSS) formerly Aliyun
       \ "Alibaba"
     --- 생략 ---
    provider> minio
    Get AWS credentials from runtime (environment variables or EC2/ECS meta data if no env vars).
    Only applies if access_key_id and secret_access_key is blank.
    Enter a boolean value (true or false). Press Enter for the default ("false").
    Choose a number from below, or type in your own value
     1 / Enter AWS credentials in the next step
       \ "false"
     2 / Get AWS credentials from the environment (env vars or IAM)
       \ "true"
    env_auth> true
    AWS Access Key ID.
    Leave blank for anonymous access or runtime credentials.
    Enter a string value. Press Enter for the default ("").
    access_key_id> minio
    AWS Secret Access Key (password)
    Leave blank for anonymous access or runtime credentials.
    Enter a string value. Press Enter for the default ("").
    secret_access_key> minio1234
    Region to connect to.
    Leave blank if you are using an S3 clone and you don't have a region.
    Enter a string value. Press Enter for the default ("").
    Choose a number from below, or type in your own value
     1 / Use this if unsure. Will use v4 signatures and an empty region.
       \ ""
     2 / Use this only if v4 signatures don't work, e.g. pre Jewel/v10 CEPH.
       \ "other-v2-signature"
    region>
    Endpoint for S3 API.
    Required when using an S3 clone.
    Enter a string value. Press Enter for the default ("").
    Choose a number from below, or type in your own value
    endpoint> http://1.1.1.1:9001
    Location constraint - must be set to match the Region.
    Leave blank if not sure. Used when creating buckets only.
    Enter a string value. Press Enter for the default ("").
    location_constraint>
    Canned ACL used when creating buckets and storing or copying objects.

    This ACL is used for creating objects and if bucket_acl isn't set, for creating buckets too.

    For more info visit https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl

    Note that this ACL is applied when server-side copying objects as S3
    doesn't copy the ACL from the source but rather writes a fresh one.
    Enter a string value. Press Enter for the default ("").
    Choose a number from below, or type in your own value
     1 / Owner gets FULL_CONTROL. No one else has access rights (default).
       \ "private"
    --- 생략 ---
    Remote config
    --------------------
    [minio]
    type = s3
    provider = minio
    env_auth = true
    access_key_id = minio
    secret_access_key = minio1234
    endpoint = http://1.1.1.1:9001
    --------------------
    y) Yes this is OK (default)
    e) Edit this remote
    d) Delete this remote
    y/e/d>
    Current remotes: y

    Name                 Type
    ====                 ====
    minio           s3

    e) Edit existing remote
    n) New remote
    d) Delete remote
    r) Rename remote
    c) Copy remote
    s) Set configuration password
    q) Quit config
    e/n/d/r/c/s/q> q

  ```
- Config 설정 정상 확인

  ```bash
    # rclone listremotes
    minio:

  ```
- Bucket 확인
  ```bash
    # rclone lsd minio:
          -1 2020-12-10 08:15:43        -1 backup
          -1 2020-12-11 15:51:25        -1 docker-registry
  ```

- 신규 Bucket(gitlabbackup) 생성
  ```bash
    # rclone mkdir minio:gitlabbackup

    # rclone lsd minio:
          -1 2020-12-10 08:15:43        -1 backup
          -1 2020-12-11 15:51:25        -1 docker-registry
          -1 2021-08-31 17:23:14        -1 gitlabbackup
  ```
  **아래와 같은 Error 는 Bucket Name 이 Rule 에 안 맞기 때문**
  ```
  ERROR : failed with 1 errors and: InvalidBucketName: The specified bucket is not valid
  ```
  - Bucket Name Rule 참고 URL : https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html

#### rclone 을 이용한 데이터 백업

- 생성된 데이터 백업 (gitlab 데이터 백업)
  - 백업 받을 데이터 확인
    ```bash
      # ls -lart /gitlab_13.8.3/data/backups/
      -rw-------  1 libstoragemgmt polkitd 6946314240  8월 19 23:13 1629382406_2021_08_19_13.8.3_gitlab_backup.tar
      -rw-------  1 libstoragemgmt polkitd 6972047360  8월 20 23:14 1629468839_2021_08_20_13.8.3_gitlab_backup.tar
      -rw-------  1 libstoragemgmt polkitd 6974402560  8월 21 23:14 1629555247_2021_08_21_13.8.3_gitlab_backup.tar
      -rw-------  1 libstoragemgmt polkitd 6976593920  8월 22 23:14 1629641637_2021_08_22_13.8.3_gitlab_backup.tar
      -rw-------  1 libstoragemgmt polkitd 7064616960  8월 23 23:14 1629728046_2021_08_23_13.8.3_gitlab_backup.tar
      -rw-------  1 libstoragemgmt polkitd 7067402240  8월 24 23:14 1629814449_2021_08_24_13.8.3_gitlab_backup.tar
      -rw-------  1 libstoragemgmt polkitd 7076403200  8월 25 23:14 1629900842_2021_08_25_13.8.3_gitlab_backup.tar
      -rw-------  1 libstoragemgmt polkitd 7079823360  8월 26 23:14 1629987244_2021_08_26_13.8.3_gitlab_backup.tar
      -rw-------  1 libstoragemgmt polkitd 7131688960  8월 27 23:14 1630073638_2021_08_27_13.8.3_gitlab_backup.tar
      -rw-------  1 libstoragemgmt polkitd 7112970240  8월 28 23:14 1630160044_2021_08_28_13.8.3_gitlab_backup.tar
      -rw-------  1 libstoragemgmt polkitd 7115366400  8월 29 23:14 1630246442_2021_08_29_13.8.3_gitlab_backup.tar
      -rw-------  1 libstoragemgmt polkitd 7118387200  8월 30 23:14 1630332843_2021_08_30_13.8.3_gitlab_backup.tar
    ```
  
  - 데이터 백업(Copy)
    - 지정된 디렉토리 또는 파일을 복사
    
      ```bash
        # rclone copy <backup_directory & file> <remote>:<bucket & directory>
        # rclone copy /gitlab_13.8.3/data/backups/ minio:/gitlabbackup/
        Transferred:             0 / 78.823 GBytes, 0%, 0 Bytes/s, ETA -
        Transferred:            0 / 12, 0%
        Elapsed time:       1m0.0s
        Transferring:
        * 1629382406_2021_08_19_….8.3_gitlab_backup.tar:  0% /6.469G, 0/s, -
        * 1629468839_2021_08_20_….8.3_gitlab_backup.tar:  0% /6.493G, 0/s, -
        * 1629555247_2021_08_21_….8.3_gitlab_backup.tar:  0% /6.495G, 0/s, -
        * 1629641637_2021_08_22_….8.3_gitlab_backup.tar:  0% /6.497G, 0/s, -
      ```
    - 최근 1일 내 생성된 데이터만 백업(옵션 : --max-age)
      - Command 로 Copy 파일 확인
        ```bash
          # rclone ls --max-age 1d /gitlab_13.8.3/data/backups/
          7118387200 1630332843_2021_08_30_13.8.3_gitlab_backup.tar
        ```
      - 데이터 백업 (최근 1일 데이터)
        ```bash
          # rclone copy --max-age 1d /gitlab_13.8.3/data/backups/ minio:/gitlabbackup/
          INFO  : 1630332843_2021_08_30_13.8.3_gitlab_backup.tar: Copied (new)
          INFO  :
          Transferred:        6.630G / 6.630 GBytes, 100%, 64.331 MBytes/s, ETA 0s
          Transferred:            1 / 1, 100%
          Elapsed time:      1m45.5s
        ```
      - 백업 데이터 확인
        ```bash
          # rclone ls minio:/gitlabbackup/
          7118387200 1630332843_2021_08_30_13.8.3_gitlab_backup.tar
        ```

- 데이터 백업(sync)
    - 변경된(delete/create) 디렉토리 또는 파일의 대한 변경 사항을 반영
    - sync 데이터 확인
      ```bash
        #  ll
          minio_test-2021-08-27.txt
          minio_test-2021-08-28.txt
          minio_test-2021-08-29.txt
          minio_test-2021-08-30.txt
          minio_test-2021-08-31.txt
      ```
    - 데이터 Sync
      ```bash
        # rclone sync ./  minio:/gitlabbackup/
        2021/08/31 18:01:56 DEBUG : Waiting for deletions to finish
        2021/08/31 18:01:56 INFO  :
        Transferred:             0 / 0 Bytes, -, 0 Bytes/s, ETA -
        Transferred:            5 / 5, 100%
        Elapsed time:         0.0s
      ```
    - 백업 데이터 확인
      ```bash
        # rclone ls minio:/gitlabbackup/
        0 minio_test-2021-08-27.txt
        0 minio_test-2021-08-28.txt
        0 minio_test-2021-08-29.txt
        0 minio_test-2021-08-30.txt
        0 minio_test-2021-08-31.txt
      ```
    - 데이터 변경에 따른 (delete/create) 확인
      - 파일 수정/삭제
        ```bash
          # rm -f minio_test-2021-08-27.txt
          # echo "testtesttest" > minio_test-2021-08-29.txt
        ```
      - 데이터 Sync
        ```bash
          # rclone sync ./  minio_test:/gitlabbackup/
          2021/08/31 18:05:45 INFO  :
          Transferred:            13 / 13 Bytes, 100%, 768 Bytes/s, ETA 0s
          Checks:                 5 / 5, 100%
          Deleted:                1 (files), 0 (dirs)
          Transferred:            1 / 1, 100%
          Elapsed time:         0.0s
        ```
      - 데이터 변경 확인
        ```bash
          # rclone ls minio_test:/gitlabbackup/
           0 minio_test-2021-08-28.txt
          13 minio_test-2021-08-29.txt
           0 minio_test-2021-08-30.txt
           0 minio_test-2021-08-31.txt
        ```

- 데이터 삭제
  ```bash
    # rclone deletefile minio_test:/gitlabbackup/1630332843_2021_08_30_13.8.3_gitlab_backup.target_host
  ```  

- 주요 옵션 
  ```
    --log-level        : 표준 레벨 포멧의 정보 레벨
    --log-file         : logfile 생성 위치
    --progress         : 상태 정보 CLI 출력
    --timeout          : 설정 시간 동안 IO 가 유휴 상태 일 경우 종료(Default:5m , disable:0)
    --copy-links       : Link 데이터 복사
    --transfers        : 병렬 처리(parallel) 할 file 수 (Default: 4)
    --checkers         : 데이터 Sync 중 병렬로 File equality 검사 수 (Default: 8)
    --ignore-checksum  : 데이터 checksum 무시
    --bwlimit          : 데이터의 Bandwidth 설정 (--bwlimit 10M 또는 --bwlimit UP:DOWN )
    위에서 부터 filter-from 은 파일에 문법이 있어서 제외할 파일 추가할파일 .. 옵션 선언하고
  ```
- 참고 URL : https://rclone.org/
    - 옵션 : https://rclone.org/docs/
    - 필터 : https://rclone.org/filtering/