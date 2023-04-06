// Change these information as your GCP ProjectId, region and zone setting
project_id = "pacific-decoder-382709" # CHANGE-THIS
region     = "asia-southeast1"        # CHANGE-THIS
zone       = "asia-southeast1-b"      # CHANGE-THIS

account_id         = "sa-github-pipeline-project"
vpc_network_name   = "vpc-github-pipeline"
gce_name           = "vm-github-pipeline"
gce_static_ip_name = "static-github-pipeline"
storage_class      = "STANDARD"
data_lake_bucket   = "datalake-github-pipeline"
table_id           = "github_events"
raw_bq_dataset     = "raw_github_events"
dev_bq_dataset     = "dev_github_events"
prod_bq_dataset    = "prod_github_events"
