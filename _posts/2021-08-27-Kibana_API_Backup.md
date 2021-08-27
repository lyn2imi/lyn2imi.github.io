---
title: Kibana API 를 통한 Space 백업 Scirpt

toc: true
toc_sticky: true

categories:
  - devops  
tags:
  - elastic
  - kibana
  - script
---

# Kibana Space 백업 구성 및 복구 테스트

### Kibana Space 백업 구성
- Kibana Space 또는 대시보드의 잘못된 수정 / 삭제를 대비 하여 백업 구성
- Kibana 에서 기본 재공 해주는 API 를 이용한 백업
  - 참고 URL : https://www.elastic.co/guide/en/kibana/master/saved-objects-api.html

### 백업 스크립트 구성
- 백업 받는 타입 정보

  ![backup_1](/images/Kibana_Backup/backup_1.png)

- 백업 스크립트
  - backup 생성 디렉토리 : "${YYYYMMDD}/서비스명/스페이스명/타입별.ndjson"
    ```bash
        #!/bin/sh

        Tday=`date +%Y%m%d`
        Backup_Type="config
        index-pattern
        visualization
        dashboard
        map
        canvas-workpad
        canvas-element
        query
        search
        url"

        Kibanas=("TESTELK1 http://localhost:5601" "TESTELK2 http://localhost:8601")


        for Kibana in "${Kibanas[@]}"
        do

            Kibana_Service=`echo $Kibana | awk '{ print $1}'`
            Kibana_Url=`echo $Kibana | awk '{ print $2}'`

            Space_Name=`curl -X GET ${Kibana_Url}/api/spaces/space | jq '.[]["id"]' | sed 's/\"//g'`

            for Space in $Space_Name
            do

            Backup_Dir="${Tday}/${Kibana_Service}/${Space}/"

            if ! [ -d ./${Backup_Dir} ] ; then
                mkdir -p ./${Backup_Dir}
            fi

            if [ ${Space} == "default" ]
            then

                curl -X POST ${Kibana_Url}/api/saved_objects/_export -H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d '
                {
                "type": "dashboard",
                "includeReferencesDeep": "true"
                }' > ./${Backup_Dir}/Space_all_export.ndjson

            else

                curl -X POST ${Kibana_Url}/s/${Space}/api/saved_objects/_export -H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d '
                {
                "type": "dashboard",
                "includeReferencesDeep": "true"
                }' > ./${Backup_Dir}/Space_all_export.ndjson

            fi

                for Type in $Backup_Type
                do

                if [ ${Space} == "default" ]
                then

                    curl -X POST ${Kibana_Url}/api/saved_objects/_export -H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d '
                    {
                        "type": "'${Type}'",
                        "includeReferencesDeep": "False"
                    }' > ./${Backup_Dir}/Space_${Type}_export.ndjson

                else

                    curl -X POST ${Kibana_Url}/s/${Space}/api/saved_objects/_export -H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d '
                    {
                        "type": "'${Type}'",
                        "includeReferencesDeep": "False"
                    }' > ./${Backup_Dir}/Space_${Type}_export.ndjson

                fi

                done

            done

        done
    ```

### 복구 테스트
- 테스트 Space : space_test
- 개별 복구(Visualizations)
  - testtest Visualization 삭제
    ![backup_2](/images/Kibana_Backup/backup_2.png)
  - 백업 받은 파일 Import
    ```bash
    # curl -XPOST http://localhost:5601/s/space_test/api/saved_objects/_import -H "kbn-xsrf: true" --form file=@./Space_visualization_export.ndjson
      {"success": true, "successCount": 1}
    ```
  - testtest Visualization 생성 확인
    ![backup_3](/images/Kibana_Backup/backup_3.png)
- Space 전체 복구
  - space 삭제

    ![backup_4](/images/Kibana_Backup/backup_4.png)
  - 백업 받은 파일 Import
    ```bash
      # curl -XPOST http://localhost:5601/s/space_test/api/saved_objects/_import -H "kbn-xsrf: true" --form file=@./Space_all_export.ndjson
        {"success":true,"successCount":3}
    ```
  - Space 생성(동일 이름)
    ![backup_5](/images/Kibana_Backup/backup_5.png)
  - Space 내 복구 확인
  
    ![backup_6](/images/Kibana_Backup/backup_6.png)