output "instance_id" {
  description = "The unique ID of the compute instance"
  value       = google_compute_instance.bcl_tdx.id
}

output "instance_self_link" {
  description = "The URI of the compute instance"
  value       = google_compute_instance.bcl_tdx.self_link
}
