locals {
  project_id = "pacific-decoder-382709"
  account_id = "sa-github-pipeline-project"
  region     = "asia-southeast1"
  zone       = "asia-southeast1-b"

  vpc_network_name   = "vpc-github-pipeline"
  gce_name           = "vm-github-pipeline"
  gce_static_ip_name = "static-github-pipeline"

  storage_class    = "STANDARD"
  data_lake_bucket = "datalake-github-pipeline"
  raw_bq_dataset   = "raw_github_events"
  table_id         = "github_events"
  dev_bq_dataset   = "dev_github_events"
  prod_bq_dataset  = "prod_github_events"
}
