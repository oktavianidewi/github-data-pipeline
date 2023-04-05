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
  table_id         = "github_events"
  raw_bq_dataset   = "raw_github_events"
  dev_bq_dataset   = "dev_github_events"
  prod_bq_dataset  = "prod_github_events"
}

variable "project_id" {
  description = "google project_id (source: .env)"
  type        = string
}

variable "account_id" {
  description = "account_id (source: .env)"
  type        = string
}

variable "region" {
  description = "region (source: .env)"
  type        = string
}

variable "zone" {
  description = "zone (source: .env)"
  type        = string
}

variable "vpc_network_name" {
  description = "vpc_network_name (source: .env)"
  type        = string
}

variable "gce_name" {
  description = "gce_name (source: .env)"
  type        = string
}

variable "gce_static_ip_name" {
  description = "gce_static_ip_name (source: .env)"
  type        = string
}

variable "storage_class" {
  description = "storage_class (source: .env)"
  type        = string
}

variable "data_lake_bucket" {
  description = "data_lake_bucket (source: .env)"
  type        = string
}

variable "table_id" {
  description = "table_id (source: .env)"
  type        = string
}

variable "raw_bq_dataset" {
  description = "raw_bq_dataset (source: .env)"
  type        = string
}

variable "dev_bq_dataset" {
  description = "dev_bq_dataset (source: .env)"
  type        = string
}

variable "prod_bq_dataset" {
  description = "prod_bq_dataset (source: .env)"
  type        = string
}
