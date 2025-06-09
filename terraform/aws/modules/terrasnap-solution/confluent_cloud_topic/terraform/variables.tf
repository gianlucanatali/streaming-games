variable "confluent_cloud_api_key" {
  description = "Confluent Cloud API Key"
  type        = string
}

variable "confluent_cloud_api_secret" {
  description = "Confluent Cloud API Secret"
  type        = string
  sensitive   = true
}

variable "confluent_cloud_cluster_id" {
  description = "Confluent Cloud Cluster ID"
  type        = string
}

variable "confluent_cloud_cluster_rest_endpoint" {
  description = "Confluent Cloud Cluster REST Endpoint"
  type        = string
}

variable "confluent_cloud_cluster_key" {
  description = "Confluent Cloud API Key"
  type        = string
}

variable "confluent_cloud_cluster_secret" {
  description = "Confluent Cloud API Secret"
  type        = string
  sensitive   = true
}
variable "topic_name" {
  description = "Name of the topic"
  type        = string
}

variable "partitions_count" {
  description = "Number of partitions for the topic"
  type        = number
}
