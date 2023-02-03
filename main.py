# [START functions_cloudevent_storage]
import functions_framework


# Triggered by a change in a storage bucket
@functions_framework.cloud_event
def gcs_load_bq(cloud_event):
    data = cloud_event.data

    from google.cloud import bigquery

    client = bigquery.Client()
    table_id = "g-sql-morphic-luminous.ds_edw.taxitrips"
    job_config = bigquery.LoadJobConfig(
        source_format=bigquery.SourceFormat.PARQUET,
    )
    uri = "gs://solution-cdc-bucket/" + data["name"]

    load_job = client.load_table_from_uri(uri, table_id, job_config=job_config)  

    load_job.result()

    destination_table = client.get_table(table_id)
    print("Loaded {} rows.".format(destination_table.num_rows))