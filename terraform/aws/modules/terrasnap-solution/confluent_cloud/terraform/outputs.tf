output "confluent_cloud_environment_id" {
  value = confluent_environment.environment.id
}

output "confluent_cloud_cluster_id" {
  value = confluent_kafka_cluster.cluster.id
}

output "confluent_cloud_cluster_bootstrap_endpoint" {
  value = confluent_kafka_cluster.cluster.bootstrap_endpoint
}

output "confluent_cloud_schema_registry_rest_endpoint" {
  value = data.confluent_schema_registry_cluster.terrasnap_schema_registry.rest_endpoint
}

output "confluent_cloud_schema_registry_id" {
  value = data.confluent_schema_registry_cluster.terrasnap_schema_registry.id
}

output "confluent_cloud_service_account_id" {
  value = confluent_service_account.app-manager.id
}

output "confluent_cloud_cluster_key" {
  value     = confluent_api_key.app-manager-kafka-api-key.id
  sensitive = true
}

output "confluent_cloud_cluster_secret" {
  value     = confluent_api_key.app-manager-kafka-api-key.secret
  sensitive = true
}

output "confluent_cloud_schema_registry_api_key" {
  value     = confluent_api_key.env-manager-schema-registry-api-key.id
  sensitive = true
}

output "confluent_cloud_schema_registry_api_secret" {
  value     = confluent_api_key.env-manager-schema-registry-api-key.secret
  sensitive = true
}

output "confluent_cloud_environment_flink_api_key" {
  value = confluent_api_key.app-manager-flink-api-key.id
}

output "confluent_cloud_environment_flink_api_secret" {
  value     = confluent_api_key.app-manager-flink-api-key.secret
  sensitive = true
}

output "confluent_cloud_environment_tableflow_api_key" {
  value = confluent_api_key.app-manager-tableflow-api-key.id
}

output "confluent_cloud_environment_tableflow_api_secret" {
  value     = confluent_api_key.app-manager-tableflow-api-key.secret
  sensitive = true
}

output "confluent_cloud_cluster_rest_endpoint" {
  value = confluent_kafka_cluster.cluster.rest_endpoint
}

output "confluent_cloud_cluster_rbac_crn" {
  value = confluent_kafka_cluster.cluster.rbac_crn
}

# Added by GN - Missing in Terrasnap
output "confluent_cloud_schema_registry_resource_name" {
  value = data.confluent_schema_registry_cluster.terrasnap_schema_registry.resource_name
}
