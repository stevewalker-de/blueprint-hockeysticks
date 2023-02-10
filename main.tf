provider "google" {
  project               = var.project_id
  region                = var.region
  zone                  = var.zone
  user_project_override = true
}

#random id
resource "random_id" "id" {
	  byte_length = 4
}

# Set up service account for the Cloud Function to execute as
resource "google_service_account" "cloud_function_service_account" {
  project      = var.project_id
  account_id   = "cloud-function-service-account-${random_id.id.hex}"
  display_name = "Service Account for Cloud Function Execution"
}

# TODO: scope this down
resource "google_project_iam_member" "cloud_function_service_account_editor_role" {
  project  = var.project_id
  role     = "roles/editor"
  member   = google_service_account.cloud_function_service_account.member

  depends_on = [
    google_service_account.cloud_function_service_account
  ]
}


# # Set up Storage Buckets
# # # Set up the raw storage bucket
# resource "google_storage_bucket" "raw_bucket" {
#   name          = "ds-edw-raw-${random_id.id.hex}"
#   location      = var.region
#   force_destroy = true

#   public_access_prevention = "enforced"
# }

# # # Set up the provisioning bucketstorage bucket
# resource "google_storage_bucket" "provisioning_bucket" {
#   name          = "ds-edw-provisioner-${random_id.id.hex}"
#   location      = var.region
#   force_destroy = true

#   public_access_prevention = "enforced"
# }

# # Set up BigQuery resources
# # # Create the BigQuery dataset
# resource "google_bigquery_dataset" "ds_edw" {

#   dataset_id    = "ds_edw"
#   friendly_name = "My EDW Dataset"
#   description   = "My EDW Dataset with tables"
#   location      = var.region
# }

# # # Create a BigQuery connection
# resource "google_bigquery_connection" "ds_connection" {
#    connection_id = "ds_connection"
#    location      = var.region
#    friendly_name = "Storage Bucket Connection"
#    cloud_resource {}
# }

# # # Grant IAM access to the BigQuery Connection account for Cloud Storage
# resource "google_project_iam_member" "bq_connection_iam_object_viewer" {
#   project  = var.project_id
#   role     = "roles/storage.objectViewer"
#   member   = "serviceAccount:${google_bigquery_connection.ds_connection.cloud_resource[0].service_account_id}"

#   depends_on = [
#     google_bigquery_connection.ds_connection
#   ]
# }

# # # Upload files
# resource "google_storage_bucket_object" "parquet_files" {
#   for_each = fileset(path.module, "assets/parquet/*")

#   bucket = google_storage_bucket.raw_bucket
#   name   = each.value
#   source = "assets/parquet/${each.value}"

# }

# # # Create a BigQuery external table
# resource "google_bigquery_table" "tbl_edw_taxi" {
#   dataset_id = google_bigquery_dataset.ds_edw.dataset_id
#   table_id   = "tbl_edw_taxi"

#   external_data_configuration {
#     autodetect    = true
#     connection_id = "${var.project_id}.${var.region}.ds_connection"
#     source_format = "CSV"
#     source_uris = ["gs://${google_storage_bucket.raw_bucket.name}/taxi-*.Parquet"]
    
#   }

#   depends_on = [
#     google_bigquery_connection.ds_connection,
#     google_storage_bucket.raw_bucket,
#     google_storage_bucket_object.parquet_files
#   ]
# }

# # TODO: Add Payment Type and Vendor Type Tables



# # Add Looker Studio Data Report Procedure
# data "template_file" "sp_lookerstudio_report" {
#   template = "${file("assets/sql/sp_lookerstudio_report.sql")}"
#   vars = {
#     project_id = var.project_id
#   }  
# }
# resource "google_bigquery_routine" "sproc_sp_demo_datastudio_report" {
#   dataset_id      = google_bigquery_dataset.ds_edw.dataset_id
#   routine_id      = "sp_lookerstudio_report"
#   routine_type    = "PROCEDURE"
#   language        = "SQL"
#   definition_body = "${data.template_file.sp_lookerstudio_report.rendered}"

#   depends_on = [
#     google_bigquery_table.tbl_edw_taxi,
#     data.template_file.sp_lookerstudio_report
#   ]
# }

# # Add Sample Queries
# data "template_file" "sp_sample_queries" {
#   template = "${file("../sql-scripts/taxi_dataset/sp_demo_datastudio_report.sql")}"
#   vars = {
#     project_id = var.project_id
#   }  
# }
# resource "google_bigquery_routine" "sp_sample_queries" {
#   dataset_id      = google_bigquery_dataset.ds_edw.dataset_id
#   routine_id      = "sp_sample_queries"
#   routine_type    = "PROCEDURE"
#   language        = "SQL"
#   definition_body = "${data.template_file.sp_sample_queries.rendered}"

#   depends_on = [
#     google_bigquery_table.tbl_edw_taxi,
#     data.template_file.sp_sample_queries
#   ]
# }


# Notebooks instance
# resource "google_notebooks_instance" "basic_instance" {
#   project                = var.project_id
#   name                   = "edw-notebook-${random_id.id.hex}"
#   provider               = google
#   location               = "us-east1-b"
#   machine_type           = "n1-standard-4"
#   post_startup_script    = "gs://solutions_terraform_assets_da/notebook_startup_script.sh"

#     vm_image {
#     project      = "deeplearning-platform-release"
#     image_family = "common-cpu-notebooks-debian-10"
#   }

# }

# # Create a Cloud Function resource
# # # Zip the function file
# data "archive_file" "bigquery_external_function_zip" {
#   type        = "zip"
#   source_dir  = "assets/bigquery-external-function" 
#   output_path = "assets/bigquery-external-function.zip"

#   depends_on = [ 
#     google_storage_bucket.provisioning_bucket
#     ]  
# }

# # # Place the function file on Cloud Storage
# resource "google_storage_bucket_object" "cloud_function_zip_upload" {
#   name   = "assets/bigquery-external-function.zip"
#   bucket = google_storage_bucket.provisioning_bucket.name
#   source = data.archive_file.bigquery_external_function_zip.output_path

#   depends_on = [ 
#     google_storage_bucket.provisioning_bucket,
#     data.archive_file.bigquery_external_function_zip
#     ]  
# }

# # # Create the function
# resource "google_cloudfunctions2_function" "function" {
#   #provider = google-beta
#   project     = var.project_id
#   name        = "bq-sp-transform-${random_id.id.hex}"
#   location    = var.region
#   description = "gcs-load-bq"

#   build_config {
#     runtime     = "python310"
#     entry_point = "bq_sp_transform"
#     source {
#       storage_source {
#         bucket = google_storage_bucket.provisioning_bucket.name
#         object = "bigquery-external-function.zip"
#       }
#     }
#   }

#   service_config {
#     max_instance_count = 1
#     available_memory   = "256M"
#     timeout_seconds    = 540
#     environment_variables = {
#         PROJECT_ID = var.project_id
#         BUCKET_ID = google_storage_bucket.raw_bucket.name
#     }
#     service_account_email = google_service_account.cloud_function_service_account.email
#   }

#   event_trigger {
#     trigger_region = var.region
#     event_type     = "google.cloud.storage.object.v1.finalized"
#     event_filters {
#          attribute = "bucket"
#          value = google_storage_bucket.raw_bucket.name
#     }
#     retry_policy   = "RETRY_POLICY_RETRY"
#     }

#   depends_on = [
#     google_storage_bucket.provisioning_bucket,
#     google_storage_bucket.raw_bucket,
#     google_project_iam_member.cloud_function_service_account_editor_role
#   ]
# } 



# resource "google_storage_bucket_object" "startfile" {
#   bucket = google_storage_bucket.raw_bucket
#   name   = "startfile"
#   source = "assets/startfile"

#   depends_on = [
#     google_cloudfunctions2_function.function
#   ]

# }