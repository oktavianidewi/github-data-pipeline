gcp_service_list = [
  "storage.googleapis.com",
]

project_id = "dtc-de-zoomcamp-2023-376219"

account_id  = "bucket-admin"
description = "Bucket Admin"
roles = [
  "roles/storage.admin",
]

# https://tech.serhatteker.com/post/2022-07/gcp-service-account-with-terraform/
