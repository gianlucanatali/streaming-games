resource "confluent_schema" "schema" {
  schema_registry_cluster {
    id = var.confluent_cloud_schema_registry_id
  }
  rest_endpoint = var.confluent_cloud_schema_registry_rest_endpoint
  subject_name  = var.subject_name
  format        = var.format
  schema        = file(var.schema_path)
  credentials {
    key    = var.confluent_cloud_schema_registry_api_key
    secret = var.confluent_cloud_schema_registry_api_secret
  }
}
