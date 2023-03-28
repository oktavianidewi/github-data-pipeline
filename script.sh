# prefect
prefect config set PREFECT_API_URL="http://127.0.0.1:4200/api"
prefect server start

# prefect register block
prefect block register -m prefect_gcp

prefect deployment apply cloud_run_job_flow-deployment.yaml
prefect agent start -q 'default'
prefect deployment run cloud-run-job-flow/cloud-run-deployment

# tf generate sa key
terraform -chdir=infra/sa output sa_private_key | base64 -di | jq > sa-project-batch.json

# copy sa file to ~
cp sa-project-batch.json ~/.gc-keys

# -t to switch between deployment
dbt build --project-dir dbt_project_github/ -t prod
dbt debug --project-dir dbt_project_github/ --profiles-dir .
