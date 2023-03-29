SHELL := /bin/bash

# initial setup will install docker, python, pipenv and all required libraries required as in Pipfile
initial-setup: 
	sudo apt-get update
	sudo apt install docker python3-pip -y
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
	prefect deployment build py_files/ingest.py:etl_web_to_gcs -n "ingest" \
		--params='{"year": 2023, "months":[1], "days":["current"]}' \
		--apply
	prefect deployment run "etl-web-to-gcs/ingest"

schedule-daily-ingestion:
	prefect deployment build py_files/ingest.py:etl_web_to_gcs -n "ingest" \
    	--params='{"year": "2023", "months":[1,2,3], "days":["current"]}' \
    	--cron='1 0 * * *' \
    	--apply

schedule-daily-model:
	prefect deployment build py_files/prefect_dbt_command.py:trigger_dbt_build -n "daily_transformation" \
    	--cron='1 1 * * *' \
    	--apply