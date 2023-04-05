resource "google_storage_bucket" "data-lake-bucket" {
  # name                        = "${local.data_lake_bucket}_${local.project_id}"
  # location                    = local.region
  # storage_class               = local.storage_class
  name                        = "${var.data_lake_bucket}_${var.project_id}"
  location                    = var.region
  storage_class               = var.storage_class
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

