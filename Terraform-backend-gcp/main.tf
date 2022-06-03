terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.20.0"
    }
  }
  backend "gcs" {
    bucket  = "tf-state-rd008-bucket"
    prefix  = "terraform/state-prod"
    credentials = "./../hardy-order-213313-39df880aaf0d.json"
  }
}



provider "google" {
  credentials = file("/../hardy-order-213313-39df880aaf0d.json")

  project = "hardy-order-213313"
  region  = "us-central1"
  zone    = "us-central1-c"
}







resource "google_storage_bucket" "tf-state" {
  name          = "tf-state-rd008-bucket"
  location      = "US"
  lifecycle {
    prevent_destroy = true
  }

versioning {
  enabled = true
}

}

