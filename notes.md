Target: 
- [DONE] create iam with terraform
- [DONE] create gcs bucket and bq with terraform
- [DONE] python code to ingest data to local
- [DONE] create downloadable service-account .json key with terraform
    - https://stackoverflow.com/questions/59736621/dumping-terraform-output-to-a-local-file
- [DONE] create block prefect programmatically
- [DONE] python code to ingest data to GCS (parquet partitioned by created_at) -> why data always stopped on month of 3?
- [DONE] create external table Bigquery to load partitioned GCS via terraform.
schema: 
```
    type                       string
    actor                      record
    repo                       record
    payload                    string
    public                       bool
    created_at    datetime64[ns, UTC]
    org                        record
    year                        int64
    month                       int64
    day                         int64
```
https://vazid.medium.com/create-dataset-and-table-in-bigquery-using-terraform-c89a5affa61b
https://github.com/terraform-google-modules/terraform-google-bigquery/blob/master/main.tf

- [DONE] install dbt bigquery local, dbt init dll
- [DONE] manage duplicate data in staging models with incremental model
- [DONE] manage partition in bigquery with dbt 
    https://docs.getdbt.com/reference/resource-configs/bigquery-configs
- [DONE] data modeling in dbt layers

- [DONE] parameterized prefect
- [DONE] python chunk when read df and load to gcs
    - write data to_parquet -> https://outerbounds.com/docs/chunk-df/
- [DONE] set prefect to run ingestion job (hourly data) every day at 00.01
- [DONE] setup prod target in profile.yml
- [DONE] create big query dataset in tf
- [DONE] switch between deployment?
- [DONE] trigger dbt command from prefect.
    - untuk jalanin command dbt seperti `dbt run` setiap setelah data ingestion
    https://prefecthq.github.io/prefect-dbt/
- [DONE] env variables
- [DONE] manage nested data in bigquery
    - can dbt-bigquery access nested json and fulfill my metrics? CAN! in bigquery, nested is better than join. since it supports bigquery nested tools. https://medium.com/google-cloud/bigquery-explained-working-with-joins-nested-repeated-data-1941646ccb5b
- looker: https://lookerstudio.google.com/s/o-d0Q4Vu5wk


create reproducible environment
- [DONE] create makefile and makesure everything works in local with makefile
    - [DONE] prefect flow can not load data from .env
- [DONE] dockerize prefect in VM
    - https://github.com/PrefectHQ/prefect/issues/5648#issuecomment-1217944604
- [DONE] port forward from VM to docker port, so orion UI ca be accessed via browser
    https://stackoverflow.com/questions/52265028/mapping-ports-in-compute-engine-with-docker
- [DONE] modify prefect flow (deployment, run) with python code
- [DONE] docker-compose run --python file (gak perlu masuk ke bash) for scheduler and historical data
- [PROGRESS] create makefile and makesure everything works in VM with makefile
    - https://medium.com/@danilo.drobac/7-a-complete-google-cloud-deployment-of-prefect-2-0-32b8e3c2febe

error: 
```
gcsfs.retry.HttpError: Anonymous caller does not have storage.buckets.get access to the Google Cloud Storage bucket. Permission 'storage.buckets.get' denied on resource (or it may not exist)., 401
```

- sa harus bikin 2, 1 sa untuk create vm, 1 sa untuk operational dalam vm
- setup dbt-bigquery in docker 
    - https://github.com/rocketechgroup/dbt-container-for-bigquery/blob/master/Dockerfile
    - https://www.dumky.net/posts/dbt-in-a-box-using-google-cloud-run-and-bigquery-to-run-your-dbt-sql-models-from-a-docker-container/
    - https://blog.devops.dev/end-to-end-dbt-project-in-google-cloud-platform-part-2-d779ce8cc3d7
    https://blog.devgenius.io/how-to-build-prefect-for-work-orchestration-1d824bd7893f
- looker 

once I clone the repository, 
```
gcloud auth login --no-launch-browser

sudo snap install docker
sudo chmod 666 /var/run/docker.sock
```

screen cheatsheet
```
tmux new -d -s prefect-server
tmux send-keys -t prefect-server 'docker-compose --profile server up' ENTER

tmux new -d -s prefect-agent
tmux send-keys -t prefect-agent 'docker-compose --profile agent up' ENTER

tmux a -t prefect-server
tmux a -t prefect-agent
```

install first time perlu pakai makefile
next run bisa pake scheduler

Download github data: 
- activity for all january: wget https://data.gharchive.org/2015-01-{01..31}-{0..23}.json.gz

historical data -> nggak perlu pakai scheduler, tapi kalo moving forward data baru butuh scheduler.

moving forward github data selalu di-update

types definition in github: https://docs.github.com/en/webhooks-and-events/events/github-event-types
