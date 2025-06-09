resource "random_string" "suffix" {
  length  = 4
  special = false
  numeric = false
  upper   = false
}

locals {
  flink_statement_builder_name  = "terrasnap_flink_statement_builder-${random_string.suffix.result}"
  flink_statement_executor_name = "terrasnap_flink_statement_executor-${random_string.suffix.result}"
}

data "confluent_organization" "main" {}

data "confluent_environment" "this" {
  id = var.confluent_cloud_environment_id
}

data "confluent_kafka_cluster" "this" {
  id = var.confluent_cloud_cluster_id

  environment {
    id = var.confluent_cloud_environment_id
  }
}

############################
### Compiling The Binary ###
############################

resource "docker_image" "builder" {
  name = "golang:1.21.5-alpine"
}

resource "docker_container" "builder" {
  name  = local.flink_statement_builder_name
  image = docker_image.builder.image_id
  rm    = true

  command = [
    "/bin/sh", "-c",
    "mkdir -p /src && cd /src && cp -r /mnt/src/* . && go mod download && go build -o /mnt/src/execute_flink_statements"
  ]

  volumes {
    host_path      = abspath("${path.module}/src")
    container_path = "/mnt/src"
  }
}

/*
  Required as there is a minor delay between the Docker container stopping and the binary being available.
  This is a workaround to ensure the binary is available before proceeding by using a sleep and postcondition.
*/
resource "time_sleep" "wait_for_binary_compile" {
  depends_on = [docker_container.builder]

  create_duration = "30s"
}

##########################
### Execute The Binary ###
##########################

resource "docker_image" "terrasnap_flink_statement_executor" {
  name = "terrasnap_flink_statement_executor:latest"
  build {
    context    = "${path.module}/src"
    dockerfile = "Dockerfile"
  }

  depends_on = [docker_container.builder, time_sleep.wait_for_binary_compile]
}

resource "docker_container" "terrasnap_flink_statement_executor" {
  name  = local.flink_statement_executor_name
  image = docker_image.terrasnap_flink_statement_executor.image_id
  rm    = true

  command = ["./bin/execute_flink_statements"]

  env = [
    "confluent_cloud_organisation_id=${data.confluent_organization.main.id}",
    "confluent_cloud_environment_id=${var.confluent_cloud_environment_id}",
    "flink_compute_pool_id=${var.flink_compute_pool_id}",
    "confluent_cloud_environment_name=${data.confluent_environment.this.display_name}",
    "confluent_cloud_cluster_name=${data.confluent_kafka_cluster.this.display_name}",
    "confluent_cloud_environment_provider=${data.confluent_kafka_cluster.this.cloud}",
    "confluent_cloud_environment_region=${data.confluent_kafka_cluster.this.region}",
    "flink_api_key=${var.confluent_cloud_environment_flink_api_key}",
    "flink_api_secret=${var.confluent_cloud_environment_flink_api_secret}",
    "flink_statement_principal=${var.confluent_cloud_service_account_id}",
    "flink_statements=${join("~~", var.flink_statements)}" # Using `~~` as a delimiter between statements for Flink to split as the env vars can only be string.
  ]

  depends_on = [docker_image.terrasnap_flink_statement_executor]
}

resource "null_resource" "wait_for_flink_executions" {
  depends_on = [docker_container.terrasnap_flink_statement_executor]

  provisioner "local-exec" {
    command = <<EOT
      docker logs -f ${local.flink_statement_executor_name} &
      docker wait ${local.flink_statement_executor_name}
    EOT
  }
}
