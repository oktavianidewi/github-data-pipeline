Target: 
- [DONE] create iam with terraform
- [DONE] create gcs bucket and bq with terraform
- run prefect in docker
- create block prefect programmatically, with defined SA ?
- run docker environment in VM
- python code to ingest data to GCS
- create external table Bigquery to load GCS via terraform
- setup dbt-bigquery in docker 
    - https://github.com/rocketechgroup/dbt-container-for-bigquery/blob/master/Dockerfile
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