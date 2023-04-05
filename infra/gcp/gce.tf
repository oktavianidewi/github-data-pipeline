# enable API
resource "google_project_service" "cloud_resource_manager" {
  project                    = local.project_id
  service                    = "cloudresourcemanager.googleapis.com"
  disable_on_destroy         = true
  disable_dependent_services = true
}

# enable GCE API
resource "google_project_service" "compute" {
  project                    = local.project_id
  service                    = "compute.googleapis.com"
  disable_on_destroy         = true
  disable_dependent_services = true
}

# setup VPC
resource "google_compute_network" "vpc_network" {
  project = local.project_id
  name    = local.vpc_network_name
}

# setup external static IP
resource "google_compute_address" "static_ip" {
  project = local.project_id
  name    = local.gce_static_ip_name
  region  = local.region
}

# setup allowed ports
resource "google_compute_firewall" "allow_tcp_ports" {
  project       = local.project_id
  name          = "allow-tcp-ports"
  network       = google_compute_network.vpc_network.name
  target_tags   = ["allow-tcp-ports"]
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["22", "4200"]
  }
}

data "google_client_openid_userinfo" "me" {}

# setup GCE
resource "google_compute_instance" "default" {
  project                   = local.project_id
  zone                      = local.zone
  name                      = local.gce_name
  machine_type              = "e2-standard-4"
  tags                      = ["allow-tcp-ports", "http-server", "https-server"]
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