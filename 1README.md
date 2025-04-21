# Automating Cloud SQL Backups using Terraform

This Terraform module automates the setup of Google Cloud resources for automated Cloud SQL backups. The solution leverages **Cloud Functions**, **Pub/Sub**, and **Cloud Scheduler** to trigger backups, retry on failure, and alert for unsuccessful attempts.

## Features
- Automatically trigger Cloud SQL backups every 30 minutes via Cloud Scheduler.
- Process backup requests using Cloud Functions.
- Retry failed backups up to 3 times with exponential backoff.
- Publish alerts to a Pub/Sub topic if retries fail.

---

## Resources Created

2. **Cloud Function**:
   - Processes Pub/Sub messages and triggers Cloud SQL backups.
   - Handles retries and publishes alerts for persistent failures.
3. **Cloud Scheduler Job**:
   - Triggers the backup process every 30 minutes.
4. **Service Account**:
   - Grants required permissions for the Cloud Function to interact with Cloud SQL and Pub/Sub.

---

## Prerequisites
1. [Terraform installed](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).
2. A GCP project with billing enabled.
3. Cloud SQL instance(s) already created.

---

## Usage

### 1. Clone the Repository
Clone the repository containing this module and navigate to the directory.

```bash
git clone <repository-url>
cd <repository-directory>
```

### 2. Configure Variables
Update the `variables.tf` file or provide the required variables during `terraform apply`.

```hcl
variable "project_id" {
  description = "Your GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region for resources"
  type        = string
  default     = "us-central1"
}

variable "pubsub_topic_name" {
  description = "Name of the Pub/Sub topic"
  type        = string
  default     = "process-pubsub-message"
}
```

### 3. Deploy the Module
Run the following commands to deploy the infrastructure.

```bash
terraform init
terraform apply
```

### 4. Verify Deployment
After successful deployment, the outputs will display:
- Pub/Sub topic name.
- Cloud Function name.
- Scheduler job name.
- Service account email.

You can verify the resources in the Google Cloud Console.

---

## Cloud Function Details

The `main.py` script is uploaded as the Cloud Function code. Below is the workflow:
1. **Triggered by Pub/Sub**:
   - The Cloud Function processes messages with `instance_id` for the Cloud SQL instance.
2. **Initiates Backup**:
   - Calls the Cloud SQL Admin API to initiate a backup.
3. **Retries on Failure**:
   - Retries the backup up to 3 times with exponential backoff.
4. **Publishes Alerts**:
   - Sends an alert message to Pub/Sub if all retries fail.

---

## Example Pub/Sub Message
The Cloud Scheduler sends the following message to the Pub/Sub topic:

```json
{
  "instance_id": "your-cloud-sql-instance-id"
}
```

---

## Outputs
Once the Terraform module is applied, you will receive the following outputs:
- `pubsub_topic_name` - The name of the created Pub/Sub topic.
- `cloud_function_name` - The name of the deployed Cloud Function.
- `scheduler_job_name` - The name of the Cloud Scheduler job.
- `service_account_email` - The email of the created service account.

---

## Clean-Up
To remove all resources, run:

```bash
terraform destroy
```

---

## Additional Notes
- Ensure Cloud SQL backups are enabled for your instance(s) in the GCP Console.
- Update the retry limit and schedule frequency as needed in the Terraform configuration.
