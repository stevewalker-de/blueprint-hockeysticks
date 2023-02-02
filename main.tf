provider "google" {
  project               = var.project_id
  region                = var.region
  user_project_override = true
}

data "google_project" "g-sql-morphic-luminous" {
}

# Create the BigQuery dataset
resource "google_bigquery_dataset" "A_DS_LAS" {

  dataset_id    = "thurs_2"
  friendly_name = "My thurs_2"
  description   = "My Dataset with Scheduled Queries"
  location      = var.region
}

resource "google_bigquery_table" "LAS1" {
  dataset_id = google_bigquery_dataset.thurs_2.dataset_id
  table_id   = "LAS1"

  external_data_configuration {
    autodetect    = true
    source_format = "CSV"
    source_uris = ["gs://steveswalker-morphic/NYC/new_york_taxi_trips-*.csv"]
  }
}

resource "google_bigquery_table" "LAS2" {
  dataset_id = google_bigquery_dataset.thurs_1.dataset_id
  table_id   = "LAS2"

  external_data_configuration {
    autodetect    = true
    source_format = "CSV"
    source_uris = ["gs://steveswalker-morphic/NYC/new_york_taxi_trips-*.csv"]
  }
} 


resource "google_notebooks_instance" "basic_instance" {
  project                = var.project_id
  name                   = "edw-notebook-intro-airmj_2"
  provider               = google
  location               = "us-east1-b"
  machine_type           = "n1-standard-4"
  post_startup_script    = "gs://solutions_terraform_assets_da/notebook_startup_script.sh"

    vm_image {
    project      = "deeplearning-platform-release"
    image_family = "common-cpu-notebooks-debian-10"


  }

}



