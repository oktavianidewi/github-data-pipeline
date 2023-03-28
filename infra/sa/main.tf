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
  account_id = "sa-via-tf"
  region     = "asia-southeast1"
  zone       = "asia-southeast1-b"

  storage_class    = "STANDARD"
  data_lake_bucket = "tf_datalake_bucket"
  dev_bq_dataset   = "dev_github"
  prod_bq_dataset  = "prod_github"
  bq_dataset       = "tf_dataset_bq"
  table_id         = "tf_table_github"
}

provider "google" {
  project = local.project_id
  region  = local.region
  zone    = local.zone
}

resource "google_service_account" "service_account" {
  account_id   = local.account_id
  display_name = "Create sa via terraform"
}

resource "google_service_account_key" "service_account_key" {
  service_account_id = google_service_account.service_account.name
  public_key_type    = "TYPE_X509_PEM_FILE"
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

resource "google_bigquery_dataset" "dev_dataset" {
  dataset_id = local.dev_bq_dataset
  project    = local.project_id
  location   = local.region
}

resource "google_bigquery_dataset" "prod_dataset" {
  dataset_id = local.prod_bq_dataset
  project    = local.project_id
  location   = local.region
}

resource "google_bigquery_table" "table" {
  dataset_id          = google_bigquery_dataset.dataset.dataset_id
  table_id            = local.table_id
  deletion_protection = false
  external_data_configuration {
    autodetect    = false # true
    source_uris   = ["gs://${google_storage_bucket.data-lake-bucket.name}/data/*"]
    source_format = "PARQUET"
    hive_partitioning_options {
      mode                     = "CUSTOM"
      source_uri_prefix        = "gs://${google_storage_bucket.data-lake-bucket.name}/data/{year:STRING}/{month:STRING}/{day:STRING}"
      require_partition_filter = false
    }
  }
  schema = <<EOF
    [
      {
        "name": "id",
        "type": "integer",
        "mode": "NULLABLE"
      },
      {
        "name": "type",
        "type": "string",
        "mode": "NULLABLE"
      },
      {
        "name": "actor",
        "type": "record",
        "mode": "NULLABLE",
        "fields": [
          {
            "name": "avatar_url",
            "type": "string",
            "mode": "NULLABLE"
          },
          {
            "name": "display_login",
            "type": "string",
            "mode": "NULLABLE"
          },
          {
            "name": "gravatar_id",
            "type": "string",
            "mode": "NULLABLE"
          },
          {
            "name": "id",
            "type": "integer",
            "mode": "NULLABLE"
          },
          {
            "name": "login",
            "type": "string",
            "mode": "NULLABLE"
          },
          {
            "name": "url",
            "type": "string",
            "mode": "NULLABLE"
          }
        ]
      },
      {
        "name": "repo",
        "type": "record",
        "mode": "NULLABLE",
        "fields": [
          {
            "name": "id",
            "type": "integer",
            "mode": "NULLABLE"
          },
          {
            "name": "name",
            "type": "string",
            "mode": "NULLABLE"
          },
          {
            "name": "url",
            "type": "string",
            "mode": "NULLABLE"
          }
        ]
      },
      {
        "name": "payload",
        "type": "string",
        "mode": "NULLABLE"
      },
      {
        "name": "public",
        "type": "boolean",
        "mode": "NULLABLE"
      },
      {
        "name": "created_at",
        "type": "timestamp",
        "mode": "NULLABLE"
      },
      {
        "name": "org",
        "type": "record",
        "mode": "NULLABLE",
        "fields": [
          {
            "name": "avatar_url",
            "type": "string",
            "mode": "NULLABLE"
          },
          {
            "name": "gravatar_id",
            "type": "string",
            "mode": "NULLABLE"
          },
          {
            "name": "id",
            "type": "integer",
            "mode": "NULLABLE"
          },
          {
            "name": "login",
            "type": "string",
            "mode": "NULLABLE"
          },
          {
            "name": "url",
            "type": "string",
            "mode": "NULLABLE"
          }
        ]
      }
    ]
    EOF
}
