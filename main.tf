module "cloud_sql_backup_cf" {
  source      = "app.terraform.io/fig-tlz/live-cloud-function-gen2/google"
  version     = "1.0.4"
  project_id  = var.project_id
  region      = var.region
  name        = var.cloud_sql_backup_cf_name
  bucket_name = module.code_bucket.name
  bundle_config = {
    source_dir  = "./backup_cloud_function"
    output_path = "cloud-sql-backup-cf.zip"
  }
  function_config = {
    entry_point        = "process_pubsub_message"
    available_memory   = "256Mi"
    available_cpu      = "167m"
    runtime            = "python310"
    timeout_seconds    = 540
    max_instance_count = 3
    min_instance_count = 0
    max_instance_request_concurrency = 1
  }
  runtime_environment_variables = {
    "PROJECT_ID"          = lookup(var.cloud_sql_backup_env, "project_id", var.project_id)
    "ALERT_TOPIC"         = lookup(var.cloud_sql_backup_env, "alert_topic", module.alert_pubsub_topic.name)
    "RETRY_LIMIT"         = lookup(var.cloud_sql_backup_env, "retry_limit", "3")
  }
  service_account_create = false
  service_account        = module.cloud_function_sa.email
  ingress_settings       = "ALLOW_INTERNAL_ONLY"
  trigger_config = {
    event_type            = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic          = module.backup_pubsub_topic.id
    trigger_region        = var.region
    service_account_email = module.cloud_function_sa.email
  }
}

module "cloud_sql_backup_scheduler" {
  source      = "app.terraform.io/fig-tlz/cloud-scheduler/google"
  version     = "1.0.1"
  project_id  = var.project_id
  region      = var.region
  name        = "backup-trigger-job-for30mins"
  schedule    = "*/30 * * * *"
  time_zone   = "Asia/Kolkata"
  pubsub_target = {
    topic_name = module.backup_pubsub_topic.id
    data       = jsonencode({ instance_id = "backup-testing" })
  }
}

# Pub/Sub Topic for Backup Trigger
module "backup_pubsub_topic" {
  source      = "app.terraform.io/fig-tlz/pubsub-topic/google"
  version     = "1.0.0"
  project_id  = var.project_id
  name        = "process-pubsub-message"
}

# Pub/Sub Topic for Alerts
module "alert_pubsub_topic" {
  source      = "app.terraform.io/fig-tlz/pubsub-topic/google"
  version     = "1.0.0"
  project_id  = var.project_id
  name        = "alert-topic"
}

# Cloud Function Service Account
module "cloud_function_sa" {
  source      = "app.terraform.io/fig-tlz/service-account/google"
  version     = "1.0.0"
  project_id  = var.project_id
  name        = "cloud-function-sa"
}
