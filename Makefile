SHELL := /bin/bash

include py_files/.env

# initial setup will install docker, python, pipenv and all required libraries required as in Pipfile
initial-setup: 
	sudo apt-get update
	sudo apt install docker docker-compose python3-pip -y
	sudo chmod 666 /var/run/docker.sock
	python3 -m pip install --user pipenv
	pipenv shell
	pipenv install

# Set up cloud infrastructure
infra-init:
	terraform -chdir=./infra/sa init

infra-up:
	terraform -chdir=./infra/sa apply

generate-sa:
	terraform -chdir=infra/sa output sa_private_key | base64 -di | jq > sa-project-batch.json

infra-down:
	terraform -chdir=infra/sa destroy
	rm -rf sa-project-batch.json

# Set up prefect server and agent
prefect-start: 
	chmod +x prefect.sh && ./prefect.sh

# Create block and ingest data
create-block:
	source py_files/.env
	python3 py_files/prefect_make_gcp_blocks.py

ingest-start:
	source py_files/.env
	prefect deployment build py_files/ingest.py:etl_web_to_gcs -n "ingestion" \
		--params='{"year": 2023, "months":[1], "days":["current"], "kwargs" : {"CHUNK_SIZE":${CHUNK_SIZE}, "GCP_PROJECT_ID":${GCP_PROJECT_ID}, "GCS_BUCKET_ID":${GCS_BUCKET_ID}, "GCS_PATH":${GCS_PATH} } }' \
		--apply
	prefect deployment run "etl-web-to-gcs/ingestion"

dbt-model-initial-run-dev:
	prefect deployment build py_files/prefect_dbt_command.py:trigger_dbt_build -n "initial-dev" \
		--params='{"target": "dev"}' \
    	--apply
	prefect deployment run "trigger-dbt-build/initial-dev"

dbt-model-initial-run-prod:
	prefect deployment build py_files/prefect_dbt_command.py:trigger_dbt_build -n "initial-prod" \
		--params='{"target": "prod"}' \
    	--apply
	prefect deployment run "trigger-dbt-build/initial-prod"

# for daily, set current year, month and day
schedule-daily-ingestion:
	prefect deployment build py_files/ingest.py:etl_web_to_gcs -n "daily-ingest" \
		--params='{"year": $(shell date +'%Y'), "months":[$(shell date +'%-m')], "days":["current"], "kwargs" : {"CHUNK_SIZE":${CHUNK_SIZE}, "GCP_PROJECT_ID":${GCP_PROJECT_ID}, "GCS_BUCKET_ID":${GCS_BUCKET_ID}, "GCS_PATH":${GCS_PATH} } }' \
    	--cron='1 0 * * *' \
    	--apply

schedule-daily-run-model-dev:
	prefect deployment build py_files/prefect_dbt_command.py:trigger_dbt_build -n "daily-transform-dev" \
		--params='{"target": "dev"}' \
    	--cron='1 1 * * *' \
    	--apply

schedule-daily-run-model-prod:
	prefect deployment build py_files/prefect_dbt_command.py:trigger_dbt_build -n "daily-transform-prod" \
		--params='{"target": "prod"}' \
    	--cron='1 1 * * *' \
    	--apply