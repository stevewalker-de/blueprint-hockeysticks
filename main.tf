# --------------------------------------------------
# TERRAFORM CONFIGURATION
# Setting the provider and the project
# --------------------------------------------------
provider "google" {
  project               = var.gcp_project
  region                = var.gcp_region
  zone                  = var.gcp_zone
  user_project_override = true
}

data "google_project" "project" {
}

# --------------------------------------------------
# RESOURCES
# Note the comments below
# --------------------------------------------------

# Enable Data Transfer Service
resource "google_project_service" "dts" {
  project                    = data.google_project.project.project_id
  service                    = "bigquerydatatransfer.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

# Service Account
resource "google_service_account" "bigquery_scheduled_queries" {
  account_id   = "bigquery-scheduled-queries"
  display_name = "BigQuery Scheduled Queries Service Account"
  description  = "Used to run BigQuery Data Transfer jobs."
}

# Wait for the new Services and Service Accounts settings to propagate
resource "time_sleep" "wait_for_settings_propagation" {
  # It can take a while for the enabled services
  # and service accounts to propagate. Experiment
  # with this value until you find a time that is
  # consistently working for all the deployments.
  create_duration = "300s"

  depends_on = [
    google_project_service.dts,
    google_service_account.bigquery_scheduled_queries
  ]
}

# IAM Permisions
resource "google_project_iam_member" "bigquery_scheduler_permissions" {
  project = data.google_project.project.project_id
  role   = "roles/iam.serviceAccountShortTermTokenMinter"
  member = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-bigquerydatatransfer.iam.gserviceaccount.com"

  depends_on = [time_sleep.wait_for_settings_propagation]
}

resource "google_project_iam_binding" "bigquery_datatransfer_admin" {
  project = data.google_project.project.project_id
  role    = "roles/bigquery.admin"
  members = ["serviceAccount:${google_service_account.bigquery_scheduled_queries.email}"]

  depends_on = [time_sleep.wait_for_settings_propagation]
}

# Create the BigQuery dataset
resource "google_bigquery_dataset" "my_dataset" {
  depends_on = [google_project_iam_member.bigquery_scheduler_permissions]

  dataset_id    = "my_dataset"
  friendly_name = "My Dataset"
  description   = "My Dataset with Scheduled Queries"
  location      = var.gcp_region
}

resource "google_bigquery_data_transfer_config" "query_config" {
  display_name           = "my-query"
  location               = var.gcp_region
  data_source_id         = "scheduled_query"
  schedule               = "every day 00:00"
  destination_dataset_id = google_bigquery_dataset.my_dataset.dataset_id
  params = {
    destination_table_name_template = "my_table"
    write_disposition               = "WRITE_TRUNCATE"
    query                           = "SELECT 1000 as total_users"
  }

  depends_on = [google_project_iam_member.bigquery_scheduler_permissions]
}