prefect deployment build ingest.py:etl_web_to_gcs -n "github-pipeline-ingest" \
    --params='{"year": "2023", "month":"01", "day":"02"}' \
    --apply

prefect deployment run "etl-web-to-gcs/github-pipeline-ingest"

# at 2023-03-29 00:01:00, then at 2023-03-30 00:01:00
prefect deployment build ingest.py:etl_web_to_gcs -n "github-pipeline-ingest" \
    --params='{"year": "2023", "month":"01", "day":"02"}' \
    --cron='1 0 * * *' \
    --apply