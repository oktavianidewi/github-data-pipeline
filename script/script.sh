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

# prefect code
prefect deployment build ingest.py:etl_web_to_gcs -n "github-pipeline-ingest" \
    --params='{"year": "2023", "month":"01", "day":"02"}' \
    --apply

prefect deployment run "etl-web-to-gcs/github-pipeline-ingest"

# at 2023-03-29 00:01:00, then at 2023-03-30 00:01:00
prefect deployment build ingest.py:etl_web_to_gcs -n "github-pipeline-ingest" \
    --params='{"year": "2023", "month":"01", "day":"02"}' \
    --cron='1 0 * * *' \
    --apply

prefect deployment build dbt_command.py:trigger_dbt_build -n "trigger-dbt-build" --apply
prefect deployment run "trigger-dbt-build/trigger-dbt-build"

prefect deployment build flow.py:greetings -n "greet" --apply
prefect deployment run flow/greet

# help of tmux to run prefect server and agent in background
tmux new -d -s mySession
tmux send-keys -t mySession.0 "echo 'Hello World'" ENTER
tmux a -t mySession