---
title: Minio Performance Tunning

toc: true
toc_sticky: true

categories:
  - devops  
tags:
  - Minio
---

## minIO 서버의 성능향상을 위한 Linux Kernel 설정
- 참고 URL : https://min.io/resources/docs/CPG-MinIO-implementation-guide.pdf
- /etc/sysctl.conf 설정 변경

  ```ini
    # maximum number of open files/file descriptors
    fs.file-max = 4194303
    # use as little swap space as possible
    vm.swappiness = 1
    # prioritize application RAM against disk/swap cache
    vm.vfs_cache_pressure = 50
    # minimum free memory
    vm.min_free_kbytes = 1000000=
    # disable the TCP timestamps option for better CPU utilization
    net.ipv4.tcp_timestamps = 0
    # enable the TCP selective acks option for better throughput
    net.ipv4.tcp_sack = 1
    # increase the maximum length of processor input queues
    net.core.netdev_max_backlog = 250000
    # increase the TCP maximum and default buffer sizes using setsockopt()
    net.core.rmem_max = 4194304
    net.core.wmem_max = 4194304
    net.core.rmem_default = 4194304
    net.core.wmem_default = 4194304
    net.core.optmem_max = 4194304
    # increase memory thresholds to prevent packet dropping:
    net.ipv4.tcp_rmem = 4096 87380 4194304
    net.ipv4.tcp_wmem = 4096 65536 4194304
    # enable low latency mode for TCP:
    net.ipv4.tcp_low_latency = 1
    # the following variable is used to tell the kernel how much of the socket buffer
    # space should be used for TCP window size, and how much to save for an application
    # buffer. A value of 1 means the socket buffer will be divided evenly between.
    # TCP windows size and application.
    net.ipv4.tcp_adv_win_scale = 1
    # maximum number of incoming connections
    net.core.somaxconn = 65535
    # maximum number of packets queued
    net.core.netdev_max_backlog = 10000
    # queue length of completely established sockets waiting for accept
    net.ipv4.tcp_max_syn_backlog = 4096
    # time to wait (seconds) for FIN packet
    net.ipv4.tcp_fin_timeout = 15
    # disable icmp send redirects
    net.ipv4.conf.all.send_redirects = 0
    # disable icmp accept redirect
    net.ipv4.conf.all.accept_redirects = 0
    # drop packets with LSR or SSR
    net.ipv4.conf.all.accept_source_route = 0
    # MTU discovery, only enable when ICMP blackhole detected
    net.ipv4.tcp_mtu_probing = 1
  ```

  ## Ramdisk 를 활용한 Cache Disk 구성
  - RAMDISK(minIO 캐시 디스크로 활용)구성으로 효율적인 유휴 메모리활용
    ```bash
        # mount -t ramfs ram /data00
    ```
  - minIO Cache 설정을 통한, IO발생시 발생되는 프리징(Access불가) 현상 개선
    ```bash
      # export MINIO_CACHE_DRIVES="/data00"
      # export MINIO_CACHE_EXPIRY=90
      # export MINIO_CACHE_EXCLUDE="*.zip;*.gz;*.tar;minio44/backup/*"
      # minio server /data{1...8}
    ```