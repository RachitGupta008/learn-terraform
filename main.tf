terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

provider "google" {
  credentials = file("hardy-order-213313-39df880aaf0d.json")

  project = "hardy-order-213313"
  region  = "us-central1"
  zone    = "us-central1-c"
}





resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance-22"
  machine_type = "f1-micro"
  tags         = ["http-server", "dev"]
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