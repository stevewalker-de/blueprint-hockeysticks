provider "google" {
  project               = var.project_id
  region                = var.region
  user_project_override = true
}

data "google_project" "g-sql-morphic-luminous" {
}

# Create the BigQuery dataset
resource "google_bigquery_dataset" "thurs_1" {

  dataset_id    = "thurs_1"
  friendly_name = "My thurs_1"
  description   = "My Dataset with Scheduled Queries"
  location      = var.region
}

resource "google_bigquery_table" "ATL1" {
  dataset_id = google_bigquery_dataset.thurs_1.dataset_id
  table_id   = "ATL1"

  external_data_configuration {
    autodetect    = true
    source_format = "CSV"
    source_uris = ["gs://steveswalker-morphic/NYC/new_york_taxi_trips-*.csv"]
  }
}

resource "google_bigquery_table" "ATL2" {
  dataset_id = google_bigquery_dataset.thurs_1.dataset_id
  table_id   = "ATL2"

  external_data_configuration {
    autodetect    = true
    source_format = "CSV"
    source_uris = ["gs://steveswalker-morphic/NYC/new_york_taxi_trips-*.csv"]
  }
} 


resource "google_notebooks_instance" "basic_instance" {
  project      = var.project_id
  name         = "edw-notebook-intro"
  provider     = google
  location     = "us-east1-b"
  machine_type = "n1-standard-4"

  vm_image {
    project      = "deeplearning-platform-release"
    image_family = "common-cpu-notebooks-debian-10"
  }

}