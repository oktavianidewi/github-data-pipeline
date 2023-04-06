resource "google_bigquery_dataset" "raw_dataset" {
  dataset_id = var.raw_bq_dataset
  project    = var.project_id
  location   = var.region
}

resource "google_bigquery_dataset" "dev_dataset" {
  dataset_id                 = var.dev_bq_dataset
  project                    = var.project_id
  location                   = var.region
  delete_contents_on_destroy = true
}

resource "google_bigquery_dataset" "prod_dataset" {
  dataset_id                 = var.prod_bq_dataset
  project                    = var.project_id
  location                   = var.region
  delete_contents_on_destroy = true
}

resource "google_bigquery_table" "table" {
  dataset_id          = google_bigquery_dataset.raw_dataset.dataset_id
  table_id            = var.table_id
  deletion_protection = false
  external_data_configuration {
    autodetect    = false # true
    source_uris   = ["gs://${google_storage_bucket.data-lake-bucket.name}/*"]
    source_format = "PARQUET"
    hive_partitioning_options {
      mode                     = "CUSTOM"
      source_uri_prefix        = "gs://${google_storage_bucket.data-lake-bucket.name}/{year:STRING}/{month:STRING}/{day:STRING}"
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
