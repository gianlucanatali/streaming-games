###########################################
######### Confluent Cloud Outputs #########
###########################################

output "environment_id" {
    value = confluent_environment.staging.id
    sensitive = true
}

output "confluent_kafka_cluster_id" {
    value = confluent_kafka_cluster.games-demo.id
    sensitive = true
}

output "confluent_ksql_cluster_id" {
    value = confluent_ksql_cluster.main.id
    sensitive = true
}

output "confluent_ksql_cluster_api_endpoint" {
    value = confluent_ksql_cluster.main.rest_endpoint
    sensitive = true
}

output "confluent_ksql_cluster_service_account_id" {
    value = confluent_service_account.app-ksql.id
    sensitive = true
}

output "confluent_ksql_cluster_api_key" {
    value = confluent_api_key.app-ksqldb-api-key.id
    sensitive = true
}

output "confluent_ksql_cluster_api_secret" {
    value = confluent_api_key.app-ksqldb-api-key.secret
    sensitive = true
}

###########################################
############### AWS Outputs ###############
###########################################

output "Games" {
  value = "https://${aws_cloudfront_distribution.games.domain_name}"
}

output cf_domain_name {
  value = aws_cloudfront_distribution.games.domain_name
}

output cf_hosted_zone_id {
  value = aws_cloudfront_distribution.games.hosted_zone_id
}
