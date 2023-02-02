provider "google" {
  project               = var.project_id
  region                = var.region
  user_project_override = true
}

data "google_project" "g-sql-morphic-luminous" {
}

# Create the BigQuery dataset
resource "google_bigquery_dataset" "A_DS_1" {

  dataset_id    = "A_DS_1"
  friendly_name = "My A_DS_1"
  description   = "My Dataset with Scheduled Queries"
  location      = var.region
}

resource "google_bigquery_table" "tbl_DW1" {
  dataset_id = google_bigquery_dataset.A_DS_1.dataset_id
  table_id   = "tbl_DW1"

  external_data_configuration {
    autodetect    = true
    source_format = "CSV"
    source_uris = ["gs://steveswalker-morphic/NYC/new_york_taxi_trips-*.csv"]
  }
}

resource "google_bigquery_table" "tbl_DW2" {
  dataset_id = google_bigquery_dataset.A_DS_1.dataset_id
  table_id   = "tbl_DW2"

  external_data_configuration {
    autodetect    = true
    source_format = "CSV"
    source_uris = ["gs://steveswalker-morphic/NYC/new_york_taxi_trips-*.csv"]
  }
} 


resource "google_notebooks_instance" "basic_instance" {
  project                = var.project_id
  name                   = "edw-notebook-intro-airmj-3"
  provider               = google
  location               = "us-east1-b"
  machine_type           = "n1-standard-4"
  post_startup_script    = "gs://solutions_terraform_assets_da/notebook_startup_script.sh"

    vm_image {
    project      = "deeplearning-platform-release"
    image_family = "common-cpu-notebooks-debian-10"


  }

}



