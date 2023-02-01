provider "google" {
  project               = var.gcp_project
  region                = var.gcp_region
  zone                  = var.gcp_zone
  user_project_override = true
}

data "google_project" "g-sql-morphic-luminous" {
}



# Create the BigQuery dataset
resource "google_bigquery_dataset" "A_1" {

  dataset_id    = "A_1"
  friendly_name = "My A_1"
  description   = "My Dataset with Scheduled Queries"
  location      = var.gcp_region
}

