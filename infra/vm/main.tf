terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.1.0"
    }
  }
}

provider "google" {
  project = "dtc-de-zoomcamp-2023-376219"
  region  = "asia-southeast1"
  zone    = "asia-southeast1-b"
}

locals {
  project_id = "dtc-de-zoomcamp-2023-376219"
  account_id = "sa-via-tf-x3"
  region     = "asia-southeast1"
  zone       = "asia-southeast1-b"

  storage_class    = "STANDARD"
  data_lake_bucket = "tf_datalake_bucket"
  dev_bq_dataset   = "dev_github"
  prod_bq_dataset  = "prod_github"
  bq_dataset       = "tf_dataset_bq"
  table_id         = "tf_table_github"
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
    "serviceAccount:${google_service_account.service_account.email}",
  ]
}



resource "google_project_service" "cloud_resource_manager" {
  service            = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "compute" {
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_compute_network" "vpc_network" {
  name = "github-pipeline-network"
}
resource "google_compute_address" "static_ip" {
  name   = "github-pipeline-vm"
  region = local.region
}

resource "google_compute_firewall" "allow_ssh" {
  name          = "allow-ssh-tcp"
  network       = google_compute_network.vpc_network.name
  target_tags   = ["allow-ssh-tcp"] // this targets our tagged VM
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["22", "4200"]
  }
}

data "google_client_openid_userinfo" "me" {}

resource "google_compute_instance" "default" {
  name                      = "github-pipeline-vm"
  machine_type              = "e2-standard-4"
  tags                      = ["allow-ssh-tcp", "http-server", "https-server"] // this receives the firewall rule
  allow_stopping_for_update = true

  metadata = {
    ssh-keys = "${split("@", data.google_client_openid_userinfo.me.email)[0]}:${tls_private_key.ssh.public_key_openssh}"
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = google_service_account.service_account.email
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20230302"
      size  = "30"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name

    access_config {
      nat_ip = google_compute_address.static_ip.address
    }
  }
}

# ssh
provider "tls" {}
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "ssh_private_key_pem" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = ".ssh/de_zoomcamp_project_dewi"
  file_permission = "0600"
}
