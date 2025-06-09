# Terrasnap - ccloud module outputs

output "confluent_cloud_0_environment_id" {
  value = module.confluent_cloud_0.confluent_cloud_environment_id
}

output "confluent_cloud_0_cluster_id" {
  value = module.confluent_cloud_0.confluent_cloud_cluster_id
}

output "confluent_cloud_0_cluster_bootstrap_endpoint" {
  value = module.confluent_cloud_0.confluent_cloud_cluster_bootstrap_endpoint
}

output "confluent_cloud_0_schema_registry_id" {
  value = module.confluent_cloud_0.confluent_cloud_schema_registry_id
}

output "confluent_cloud_0_service_account_id" {
  value = module.confluent_cloud_0.confluent_cloud_service_account_id
}

output "confluent_cloud_0_cluster_key" {
  value     = module.confluent_cloud_0.confluent_cloud_cluster_key
  sensitive = true
}

output "confluent_cloud_0_cluster_secret" {
  value     = module.confluent_cloud_0.confluent_cloud_cluster_secret
  sensitive = true
}

output "confluent_cloud_0_schema_registry_api_key" {
  value     = module.confluent_cloud_0.confluent_cloud_schema_registry_api_key
  sensitive = true
}

output "confluent_cloud_0_schema_registry_api_secret" {
  value     = module.confluent_cloud_0.confluent_cloud_schema_registry_api_secret
  sensitive = true
}

output "confluent_cloud_0_environment_flink_api_key" {
  value = module.confluent_cloud_0.confluent_cloud_environment_flink_api_key
}

output "confluent_cloud_0_environment_flink_api_secret" {
  value     = module.confluent_cloud_0.confluent_cloud_environment_flink_api_secret
  sensitive = true
}

output "confluent_cloud_0_environment_tableflow_api_key" {
  value = module.confluent_cloud_0.confluent_cloud_environment_tableflow_api_key
}

output "confluent_cloud_0_environment_tableflow_api_secret" {
  value     = module.confluent_cloud_0.confluent_cloud_environment_tableflow_api_secret
  sensitive = true
}

output "confluent_cloud_0_cluster_rest_endpoint" {
  value = module.confluent_cloud_0.confluent_cloud_cluster_rest_endpoint
}


output "confluent_cloud_0_cluster_rbac_crn" {
  value = module.confluent_cloud_0.confluent_cloud_cluster_rbac_crn
}

output "confluent_cloud_0_schema_registry_rest_endpoint" {
  value = module.confluent_cloud_0.confluent_cloud_schema_registry_rest_endpoint
}

# Added by GN - Missing in Terrasnap
output "confluent_cloud_0_schema_registry_resource_name" {
  value = module.confluent_cloud_0.confluent_cloud_schema_registry_resource_name
}

output "flink_compute_pool_id" {
  value = module.confluent_cloud_flink_compute_pool_3.flink_compute_pool_id
}

output "flink_compute_pool_name" {
  value = module.confluent_cloud_flink_compute_pool_3.flink_compute_pool_name
}
