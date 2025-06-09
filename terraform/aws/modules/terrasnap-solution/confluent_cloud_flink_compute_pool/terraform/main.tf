resource "random_string" "suffix" {
  length  = 4
  special = false
  numeric = false
  upper   = false
}

data "confluent_kafka_cluster" "this" {
  id = var.confluent_cloud_cluster_id

  environment {
    id = var.confluent_cloud_environment_id
  }
}

resource "confluent_flink_compute_pool" "flink_pool" {
  display_name = var.flink_compute_pool_name
  cloud        = data.confluent_kafka_cluster.this.cloud
  region       = data.confluent_kafka_cluster.this.region
  max_cfu      = ceil(var.flink_max_cfu / 10) * 10 // Ensures that the CFU is a multiple of 10 as required.

  environment {
    id = var.confluent_cloud_environment_id
  }
}
