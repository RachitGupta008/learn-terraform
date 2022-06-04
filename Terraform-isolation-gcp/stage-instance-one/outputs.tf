output "instance-details" {
  value = google_compute_instance.vm_instance
  sensitive = true
}

