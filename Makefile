SHELL := /bin/bash

include .env

#######################################################################
# vm setup

install-terraform: 
	chmod +x script/install-terraform.sh && script/install-terraform.sh
	
initial-setup-vm:
	sudo apt-get update -y
	sudo apt install docker docker-compose python3-pip jq -y
	sudo chmod 666 /var/run/docker.sock

# Set up cloud infrastructure
infra-init-vm:
	terraform -chdir=./infra/gcp init

infra-up-vm:
	terraform -chdir=infra/gcp apply -var-file=terraform.tfvars

generate-service-account-vm:
	terraform -chdir=infra/gcp output sa_private_key | base64 -di | jq > sa-github-pipeline-project.json

infra-down-vm:
	terraform -chdir=infra/gcp destroy -var-file=terraform.tfvars
	rm -rf sa-github-pipeline-project.json

copy-service-account-to-vm:
	gcloud compute scp --project="${GCP_PROJECT_ID}" --zone="${GCP_ZONE}" sa-github-pipeline-project.json ${GCP_EMAIL_WITHOUT_DOMAIN_NAME}@vm-github-pipeline:"~/github-data-pipeline"
	
# Running up prefect server and agent
docker-spin-up:
	chmod +x script/build.sh && script/build.sh
	docker-compose up -d server
	docker-compose up -d agent

docker-spin-down:
	docker-compose down --remove-orphans

# Create prefect block
block-create:
	docker-compose run job flows/gcp_blocks.py

# Run and set schedule for data ingestion
ingest-data:
	docker-compose run job flows/deploy_ingest.py \
		--name "github-data" \
		--params='{"year": 2023, "months":[1,2,3,4], "days":["current"], "kwargs" : {"CHUNK_SIZE":${CHUNK_SIZE}, "GCP_PROJECT_ID":${GCP_PROJECT_ID}, "GCS_BUCKET_ID":${GCS_BUCKET_ID}, "GCS_PATH":${GCS_PATH} } }'

set-daily-ingest-data:
	docker-compose run job flows/deploy_ingest.py \
		--name "github-data" \
		--params='{"year": $(shell date +'%Y'), "months":[$(shell date +'%-m')], "days":["current"], "kwargs" : {"CHUNK_SIZE":${CHUNK_SIZE}, "GCP_PROJECT_ID":${GCP_PROJECT_ID}, "GCS_BUCKET_ID":${GCS_BUCKET_ID}, "GCS_PATH":${GCS_PATH} } }' \
		--cron "1 0 * * *"

# Run and set schedule for data transformation 
transform-data-dev:
	docker-compose run job flows/deploy_dbt_command.py \
		--target dev \
		--type run

transform-data-prod:
	docker-compose run job flows/deploy_dbt_command.py \
		--target prod \
		--type run

set-daily-transform-data-prod:
	docker-compose run job flows/deploy_dbt_command.py \
		--target prod \
		--type run \
		--cron '1 3 * * *'

generate-sa:
	sudo apt install jq -y
	terraform -chdir=infra/vm output sa_private_key | base64 -di | jq > sa-github-pipeline-project.json

#######################################################################
# local setup

initial-setup: 
	sudo apt-get update
	sudo apt install docker docker-compose python3-pip make -y
	sudo chmod 666 /var/run/docker.sock
	
infra-init:
	terraform -chdir=./infra/sa init

infra-up:
	terraform -chdir=./infra/sa apply

infra-down:
	terraform -chdir=infra/sa destroy
	rm -rf sa-project-batch.json
	
prefect-start: 
	chmod +x script/prefect.sh && script/prefect.sh

local-ingest-start:
	source .env
	prefect deployment build flows/ingest.py:etl_web_to_gcs -n "ingestion" \
		--params='{"year": 2023, "months":[4], "days":["current"], "kwargs" : {"CHUNK_SIZE":${CHUNK_SIZE}, "GCP_PROJECT_ID":${GCP_PROJECT_ID}, "GCS_BUCKET_ID":${GCS_BUCKET_ID}, "GCS_PATH":${GCS_PATH} } }' \
		--apply
	prefect deployment run "etl-web-to-gcs/ingestion"


dbt-model-initial-run-dev:
	prefect deployment build flows/prefect_dbt_command.py:trigger_dbt_build -n "initial-dev" \
		--params='{"target": "dev"}' \
    	--apply
	prefect deployment run "trigger-dbt-build/initial-dev"

dbt-model-initial-run-prod:
	prefect deployment build flows/prefect_dbt_command.py:trigger_dbt_build -n "initial-prod" \
		--params='{"target": "prod"}' \
    	--apply
	prefect deployment run "trigger-dbt-build/initial-prod"

# for daily, set current year, month and day
schedule-daily-ingestion:
	prefect deployment build flows/ingest.py:etl_web_to_gcs -n "daily-ingest" \
		--params='{"year": $(shell date +'%Y'), "months":[$(shell date +'%-m')], "days":["current"], "kwargs" : {"CHUNK_SIZE":${CHUNK_SIZE}, "GCP_PROJECT_ID":${GCP_PROJECT_ID}, "GCS_BUCKET_ID":${GCS_BUCKET_ID}, "GCS_PATH":${GCS_PATH} } }' \
    	--cron='1 0 * * *' \
    	--apply

schedule-daily-run-model-dev:
	prefect deployment build flows/prefect_dbt_command.py:trigger_dbt_build -n "daily-transform-dev" \
		--params='{"target": "dev"}' \
    	--cron='1 1 * * *' \
    	--apply

schedule-daily-run-model-prod:
	prefect deployment build flows/prefect_dbt_command.py:trigger_dbt_build -n "daily-transform-prod" \
		--params='{"target": "prod"}' \
    	--cron='1 1 * * *' \
    	--apply

#######################################################################
