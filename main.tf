provider "google" {
  project               = var.project_id
  region                = var.region
  user_project_override = true
}

data "google_project" "g-sql-morphic-luminous" {
}

# Create the BigQuery dataset
resource "google_bigquery_dataset" "ds_edw" {

  dataset_id    = "ds_edw"
  friendly_name = "My EDW Dataset"
  description   = "My EDW Dataset with tables"
  location      = var.region
}

resource "google_bigquery_table" "tbl_edw_taxi" {
  dataset_id = google_bigquery_dataset.ds_edw.dataset_id
  table_id   = "tbl_edw_taxi"

  external_data_configuration {
    autodetect    = true
    source_format = "CSV"
    source_uris = ["gs://solution-data-taxi-trips/new_york_taxi_trips-*.csv"]
  }
}


resource "google_notebooks_instance" "basic_instance" {
  project                = var.project_id
  name                   = "edw-notebook-intro-0204v1"
  provider               = google
  location               = "us-east1-b"
  machine_type           = "n1-standard-4"
  post_startup_script    = "gs://solutions_terraform_assets_da/notebook_startup_script.sh"

    vm_image {
    project      = "deeplearning-platform-release"
    image_family = "common-cpu-notebooks-debian-10"


  }

}


resource "google_cloudfunctions2_function" "function" {
  #provider = google-beta
  project     = var.project_id
  name        = "gcs-load-bq"
  location    = "us-central1"
  description = "gcs-load-bq"

  build_config {
    runtime     = "python310"
    entry_point = "gcs_load_bq"
    source {
      storage_source {
        bucket = "solution-cdc-assets-sandbox"
        object = "function.zip"
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  }

  event_trigger {
    trigger_region = "us-central1"
    event_type     = "google.cloud.storage.object.v1.finalized"
    event_filters {
         attribute = "bucket"
         value = "solution-cdc-bucket-sandbox"
    }
    retry_policy   = "RETRY_POLICY_RETRY"
  }

} 