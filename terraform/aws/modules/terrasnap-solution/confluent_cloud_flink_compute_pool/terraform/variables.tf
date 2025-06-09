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

variable "flink_compute_pool_name" {
  description = "Flink compute pool name."
  type        = string
}

variable "flink_max_cfu" {
  description = "Maximum number of Confluent Flink Units (CFUs) that the Flink compute pool should auto-scale to."
  type        = number
  default     = 10
}
