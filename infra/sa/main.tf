terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.5.0"
    }
  }
}

locals {
  project_id = "dtc-de-zoomcamp-2023-376219"
  account_id = "test-sa-tf"
  region     = "asia-southeast1"
  zone       = "asia-southeast1-b"

  storage_class    = "STANDARD"
  data_lake_bucket = "test_datalake_bucket"
  bq_dataset       = "test_dataset_bq"
}

provider "google" {
  project = local.project_id
  region  = local.region
  zone    = local.zone
}

resource "google_service_account" "service_account" {
  account_id   = local.account_id
  display_name = "Test create sa via terraform"
}

resource "google_project_iam_binding" "service_account" {
  project = local.project_id

  for_each = toset([
    "roles/storage.admin",
    "roles/bigquery.admin",
    "roles/cloudsql.admin",
    "roles/secretmanager.secretAccessor",
    "roles/datastore.owner"
  ])
  role = each.key
  members = [
    "serviceAccount:${local.account_id}@${local.project_id}.iam.gserviceaccount.com",
  ]
}

# GCS and Bigquery

resource "google_storage_bucket" "data-lake-bucket" {
  name                        = "${local.data_lake_bucket}_${local.project_id}"
  location                    = local.region
  storage_class               = local.storage_class
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 30
    }
  }
  force_destroy = true
}

resource "google_bigquery_dataset" "dataset" {
  dataset_id = local.bq_dataset
  project    = local.project_id
  location   = local.region
}

