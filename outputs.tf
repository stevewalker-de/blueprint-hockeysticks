output "ds_friendly_name" {
  value = "blah" #google_bigquery_dataset.ds_edw.friendly_name
}

output "function_uri" {
  value = google_cloudfunctions2_function.function.service_config[0].uri
}

