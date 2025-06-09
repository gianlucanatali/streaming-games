output "flink_compute_pool_id" {
  value = confluent_flink_compute_pool.flink_pool.id
}

output "flink_compute_pool_name" {
  value = confluent_flink_compute_pool.flink_pool.display_name
}
