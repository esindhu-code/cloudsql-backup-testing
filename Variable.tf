variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region for resources"
  type        = string
  default     = "us-central1"
}

variable "cloud_sql_backup_cf_name" {
  description = "Name of the Cloud Function for Cloud SQL backup"
  type        = string
  default     = "cloud-sql-backup-cf"
}

variable "cloud_sql_backup_env" {
  description = "Environment variables for the Cloud SQL backup function"
  type        = map(string)
  default     = {}
}
