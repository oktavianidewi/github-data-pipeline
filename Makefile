SHELL := /bin/bash

include flows/.env

# initial setup will install docker, python, pipenv and all required libraries required as in Pipfile
initial-setup: 
	sudo apt-get update
	sudo apt install docker docker-compose python3-pip make -y
	sudo chmod 666 /var/run/docker.sock
	python3 -m pip install --user pipenv
	pipenv shell
	pipenv install

install-terraform: 
	wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
	echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
	sudo apt-get update -y
	sudo apt install terraform -y
	
install-docker-compose:
	rmm -rf /usr/local/bin/docker-compose
	curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
	chmod +x /usr/local/bin/docker-compose

initial-setup-vm:
	sudo apt-get update -y
	sudo apt install docker docker-compose python3-pip make jq -y
	sudo chmod 666 /var/run/docker.sock
	pip install -r requirements.txt

# Set up cloud infrastructure
infra-init:
	terraform -chdir=./infra/sa init

infra-up:
	terraform -chdir=./infra/sa apply

generate-sa:
	terraform -chdir=infra/vm output sa_private_key | base64 -di | jq > sa-project-batch.json

infra-down:
	terraform -chdir=infra/sa destroy
	rm -rf sa-project-batch.json

# Set up prefect server and agent
prefect-start: 
	chmod +x prefect.sh && ./prefect.sh

docker-prefect-start: 
	chmod +x prefect-docker.sh && ./prefect-docker.sh

# Create block and ingest data
create-block:
	source flows/.env
	python3 flows/prefect_make_gcp_blocks.py

ingest-start:
	source flows/.env
	prefect deployment build flows/ingest.py:etl_web_to_gcs -n "ingestion" \
		--params='{"year": 2023, "months":[1], "days":["current"], "kwargs" : {"CHUNK_SIZE":${CHUNK_SIZE}, "GCP_PROJECT_ID":${GCP_PROJECT_ID}, "GCS_BUCKET_ID":${GCS_BUCKET_ID}, "GCS_PATH":${GCS_PATH} } }' \
		--apply
	prefect deployment run "etl-web-to-gcs/ingestion"

docker-historical-ingest-start:
	docker-compose --profile historical-ingest up

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