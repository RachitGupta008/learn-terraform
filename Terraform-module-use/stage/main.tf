terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.20.0"
    }
  }
  backend "gcs" {
    bucket  = "tf-state-rd008-bucket"
    prefix  = "terraform/state-stage-instance-ms-1"
    credentials = "./../../hardy-order-213313-39df880aaf0d.json"
  }
}

provider "google" {
  credentials = file("/../../hardy-order-213313-39df880aaf0d.json")

  project = "hardy-order-213313"
  region  = "us-central1"
  zone    = "us-central1-c"
}

module "server-cluster" {
    source = "../../../modules-terraform/server-cluster"
    project_name="hardy-order-213313"
    name="stage-ms-1"
    env="stage"
    network_tag_list_http=["http-server", "stage"]
    machine_type="f1-micro"
}