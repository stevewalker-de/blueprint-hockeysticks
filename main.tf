provider "google" {
  project               = var.project_id
  region                = var.region
  user_project_override = true
}

data "google_project" "g-sql-morphic-luminous" {
}

# Create the BigQuery dataset
resource "google_bigquery_dataset" "A_1" {

  dataset_id    = "A_1"
  friendly_name = "My A_1"
  description   = "My Dataset with Scheduled Queries"
  location      = var.region
}

resource "google_bigquery_table" "nyc" {
  dataset_id = google_bigquery_dataset.A_1.dataset_id
  table_id   = "nyc"

  external_data_configuration {
    autodetect    = true
    source_format = "CSV"
    source_uris = ["gs://steveswalker-morphic/NYC/new_york_taxi_trips-*.csv"]
  }
}

resource "google_bigquery_table" "nyc2" {
  dataset_id = google_bigquery_dataset.A_1.dataset_id
  table_id   = "nyc2"

  external_data_configuration {
    autodetect    = true
    source_format = "CSV"
    source_uris = ["gs://steveswalker-morphic/NYC/new_york_taxi_trips-*.csv"]
  }
}
