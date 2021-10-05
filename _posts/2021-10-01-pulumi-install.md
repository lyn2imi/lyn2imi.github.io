---
title: Pulumi 를 활용한 AWS 구성(테스트중...)

toc: true
toc_sticky: true

categories:
  - devops
tags:
  - aws
  - pulumi
---

# pulumi

 - Infrastructure as Code (IaC) 플랫폼
 - 다양한 프로그래밍 언어 지원
   ```
   TypeScript
   JavaScript
   Python
   Go
   .NET
   ```
  - 다양한 클라우드 플랫폼 지원
    ```
    AWS
    Google Cloud Platform (GCP)
    Azure
    Kubernetes
    ```

- Pulumi Install (/w Linux)

    ```bash
    # curl -fsSL https://get.pulumi.com | sh
    === Installing Pulumi v3.13.2 ===
    + Downloading https://get.pulumi.com/releases/sdk/pulumi-v3.13.2-linux-x64.tar.gz...
    % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                    Dload  Upload   Total   Spent    Left  Speed
    100 61.0M  100 61.0M    0     0  29.2M      0  0:00:02  0:00:02 --:--:-- 29.2M
    + Extracting to /root/.pulumi/bin
    + Adding $HOME/.pulumi/bin to $PATH in /root/.bashrc

    === Pulumi is now installed! 🍹 ===
    + Please restart your shell or add /root/.pulumi/bin to your $PATH
    + Get started with Pulumi: https://www.pulumi.com/docs/quickstart
    ```

- 작성중