resource "confluent_kafka_topic" "topic" {
  kafka_cluster {
    id = var.confluent_cloud_cluster_id
  }

  topic_name       = var.topic_name
  partitions_count = var.partitions_count
  rest_endpoint    = var.confluent_cloud_cluster_rest_endpoint

  credentials {
    key    = var.confluent_cloud_cluster_key
    secret = var.confluent_cloud_cluster_secret
  }
}
