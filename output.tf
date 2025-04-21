# Output file for the Terraform module

output "pubsub_topic_name" {
  description = "The name of the Pub/Sub topic created for backup"
  value       = google_pubsub_topic.backup_topic.name
}

output "cloud_function_name" {
  description = "The name of the Cloud Function deployed for processing Pub/Sub messages"
  value       = google_cloudfunctions2_function.backup_function.name
}

output "scheduler_job_name" {
  description = "The name of the Cloud Scheduler job created"
  value       = google_cloud_scheduler_job.backup_scheduler.name
}

output "service_account_email" {
  description = "The email of the service account created for Cloud Function"
  value       = google_service_account.cloud_function_sa.email
}
