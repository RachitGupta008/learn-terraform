terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.20.0"
    }
  }
}

provider "google" {
  credentials = file("hardy-order-213313-39df880aaf0d.json")

  project = "hardy-order-213313"
  region  = "us-central1"
  zone    = "us-central1-c"
}

provider "google-beta" {
  credentials = file("hardy-order-213313-39df880aaf0d.json")

  project = "hardy-order-213313"
  region  = "us-central1"
  zone    = "us-central1-c"
  
}

variable "network_tag_list_dev" {

type = list
default = ["http-server", "dev"]  
}

variable "additional_disk_size"{
  default=32
}

variable "boot_disk_size"{
  default = 16
}

resource "google_compute_instance_template" "test_terrafrom_template" {
name        = "test-terraform-template"
description = "This template is used to create app server instances."
machine_type = "f1-micro"
tags         = var.network_tag_list_dev
metadata_startup_script = "sudo apt update && sudo apt -y install apache2"


disk {
    source_image      = "debian-cloud/debian-9"
    auto_delete       = true
    boot              = true
  }

labels = {
    environment = "dev"
  }

  network_interface {
    network= "default"
    access_config {
    }
  }

  lifecycle {
    create_before_destroy = true
  }




}

resource "google_compute_global_address" "tf_ip" {

  name = "tf-static-ip"
  lifecycle {
    create_before_destroy = true
  }
}

# forwarding rule
resource "google_compute_global_forwarding_rule" "tf_forwarding_rule" {
  name                  = "tf-forwarding-rule"
  provider      = google-beta
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "80"
  target                = google_compute_target_http_proxy.tf_proxy.id
  ip_address            = google_compute_global_address.tf_ip.id
}

# http proxy
resource "google_compute_target_http_proxy" "tf_proxy" {
  name     = "tf-target-http-proxy"

  url_map  = google_compute_url_map.default.id
}

# url map
resource "google_compute_url_map" "default" {
  name            = "tf-url-map"

  default_service = google_compute_backend_service.default.id
}


# backend service with custom request and response headers
resource "google_compute_backend_service" "default" {
  name                     = "tf-backend-service"
  protocol                 = "HTTP"
  load_balancing_scheme    = "EXTERNAL"
  timeout_sec              = 10
  enable_cdn               = true
  health_checks            = [google_compute_health_check.autohealing.id]
  backend {
    group           = google_compute_region_instance_group_manager.terraform_appserver.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}


resource "google_compute_instance_template" "test_terrafrom_template_updated" {
name        = "test-terraform-template-1"
description = "This template is used to create app server instances."
machine_type = "f1-micro"
tags         = var.network_tag_list_dev
metadata = {
    startup-script = "sudo apt update && sudo apt -y install apache2"
  }


disk {
    source_image      = "debian-cloud/debian-9"
    auto_delete       = true
    boot              = true
  }

labels = {
    environment = "dev"
  }

  network_interface {
    network= "default"
    access_config {
    }
  }

lifecycle {
  create_before_destroy = true
}


}


resource "google_compute_health_check" "autohealing" {
  name                = "autohealing-terraform-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10 # 50 seconds

  http_health_check {
    request_path = "/"
    port         = "80"
  }
}



resource "google_compute_region_instance_group_manager" "terraform_appserver" {
  name = "appserver-terraform"

  base_instance_name         = "terraform-app"
  region                     = "us-central1"
  distribution_policy_zones  = ["us-central1-a", "us-central1-f"]
  version {
    instance_template = google_compute_instance_template.test_terrafrom_template_updated.id
    name = "primary"
  }
  target_size  = 3
   auto_healing_policies {
    health_check      = google_compute_health_check.autohealing.id
    initial_delay_sec = 300
  }


}




data "google_compute_subnetwork" "my-subnetwork" {
  name   = "default-us-east1"
  region = "us-east1"
}

output "google_subnets" {
  value = data.google_compute_subnetwork.my-subnetwork
}


data "google_compute_region_instance_group" "instance_group_data" {
  self_link = google_compute_region_instance_group_manager.terraform_appserver.instance_group
}

output "instance_info" {
  value = data.google_compute_region_instance_group.instance_group_data.instances
  
}


resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance-22"
  machine_type = "f1-micro"
  tags         = var.network_tag_list_dev
metadata_startup_script = "sudo apt update && sudo apt -y install apache2"

	boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
	  size= 32
    }
  }

	network_interface {
    network = "default"
    access_config {
    }
  }
}