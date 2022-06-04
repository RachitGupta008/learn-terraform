terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.20.0"
    }
  }
  backend "gcs" {
    bucket  = "tf-state-rd008-bucket"
    prefix  = "terraform/state-stage-instance-2"
    credentials = "./../../hardy-order-213313-39df880aaf0d.json"
  }
}



provider "google" {
  credentials = file("/../../hardy-order-213313-39df880aaf0d.json")

  project = "hardy-order-213313"
  region  = "us-central1"
  zone    = "us-central1-c"
}
//Using this way we can fetch the output variables from a remote state and put it as argument to the startup script of an instance 
//This can be used in setting of environment vairable etc

resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance-2"
  machine_type = "f1-micro"
  tags         = ["http-server"]
metadata_startup_script = templatefile("user-data.sh", {
    db_address= data.terraform_remote_state.state-instance-1.outputs.instance-details2
   
  })



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

data "terraform_remote_state" "state-instance-1" {
  backend = "gcs"
  config = {
    bucket  = "tf-state-rd008-bucket"
    prefix  = "terraform/state-stage-instance-1/"
    credentials = "./../../hardy-order-213313-39df880aaf0d.json"
  }
}

output "instance-2-ip" {
  value = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}
