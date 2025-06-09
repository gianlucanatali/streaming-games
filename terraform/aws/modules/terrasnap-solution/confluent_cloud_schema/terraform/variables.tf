variable "confluent_cloud_api_key" {
  description = "Confluent Cloud API Key"
  type        = string
}

variable "confluent_cloud_api_secret" {
  description = "Confluent Cloud API Secret"
  type        = string
  sensitive   = true
}

variable "confluent_cloud_schema_registry_id" {
  description = "Confluent Cloud Schema Registry ID"
  type        = string
}

variable "confluent_cloud_schema_registry_rest_endpoint" {
  description = "Confluent Cloud Schema Registry REST Endpoint"
  type        = string
}

variable "confluent_cloud_schema_registry_api_key" {
  description = "Confluent Cloud Schema Registry API Key"
  type        = string
}

variable "confluent_cloud_schema_registry_api_secret" {
  description = "Confluent Cloud Schema Registry API Secret"
  type        = string
}

variable "subject_name" {
  description = "Subject Name"
  type        = string
}

variable "format" {
  description = "Format"
  type        = string
}

variable "schema_path" {
  description = "Schema Path"
  type        = string
}
