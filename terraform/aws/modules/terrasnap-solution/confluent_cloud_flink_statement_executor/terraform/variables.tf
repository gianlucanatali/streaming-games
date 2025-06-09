variable "confluent_cloud_api_key" {
  description = "Confluent Cloud API Key (also referred as Cloud API ID)"
  type        = string
}

variable "confluent_cloud_api_secret" {
  description = "Confluent Cloud API Secret"
  type        = string
  sensitive   = true
}

variable "confluent_cloud_environment_id" {
  description = "Confluent Cloud environment ID."
  type        = string
}

variable "confluent_cloud_cluster_id" {
  description = "Confluent Cloud cluster ID."
  type        = string
}

variable "confluent_cloud_service_account_id" {
  description = "Confluent Cloud environment app manager service account ID."
  type        = string
}

variable "flink_compute_pool_id" {
  description = "Confluent Cloud Flink compute pool ID."
  type        = string
}

variable "confluent_cloud_environment_flink_api_key" {
  description = "Confluent Cloud Flink API key."
  type        = string
}

variable "confluent_cloud_environment_flink_api_secret" {
  description = "Confluent Cloud Flink API secret."
  type        = string
  sensitive   = true
}

variable "flink_statements" {
  description = "Flink statement that registers the AI model in the Flink workspace."
  type        = list(string)
  default     = [""]
}