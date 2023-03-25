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
- [PARTIAL] data modeling in dbt layers
- parameterized prefect
- set prefect to run ingestion job (hourly data) every 10 min
- trigger dbt command from prefect 
    https://prefecthq.github.io/prefect-dbt/
- [DONE] manage nested data in bigquery
    - can dbt-bigquery access nested json and fulfill my metrics? CAN! in bigquery, nested is better than join. since it supports bigquery nested tools. https://medium.com/google-cloud/bigquery-explained-working-with-joins-nested-repeated-data-1941646ccb5b

create reproducible environment
- setup dbt-bigquery in docker 
    - https://github.com/rocketechgroup/dbt-container-for-bigquery/blob/master/Dockerfile
    - https://www.dumky.net/posts/dbt-in-a-box-using-google-cloud-run-and-bigquery-to-run-your-dbt-sql-models-from-a-docker-container/
    - https://blog.devops.dev/end-to-end-dbt-project-in-google-cloud-platform-part-2-d779ce8cc3d7
- create daily scheduler
- run prefect in docker
    - https://medium.com/@danilo.drobac/7-a-complete-google-cloud-deployment-of-prefect-2-0-32b8e3c2febe
- run docker environment in VM
- looker 


install first time perlu pakai makefile
next run bisa pake scheduler

Download github data: 
- activity for all january: wget https://data.gharchive.org/2015-01-{01..31}-{0..23}.json.gz

historical data -> nggak perlu pakai scheduler, tapi kalo moving forward data baru butuh scheduler.

moving forward github data selalu di-update

types definition in github: https://docs.github.com/en/webhooks-and-events/events/github-event-types

## Problem Description
GitHub is where people build software. More than 100 million people use GitHub to discover, fork, and contribute to over 330 million projects.

Interesting metrics (2023-current): 
user's metrics:
- daily most active repository (counted by push) 20
- daily most active users (counter by number of push) 20
- daily most active organizations (counter by number of push) 20
- daily heatmap graph showing active hour 
- daily number of event based on its type (PushEvent: 100, PullRequestEvent:300, etc)

https://gitstar-ranking.com/

## Cloud

## Data Ingestion (batch)

## Data Warehouse

## Transformation (dbt)

## Dashboard

## Reproducability