terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "1.62.0"
    }
  }
}

data "confluent_organization" "ccloud" {}

data "confluent_flink_region" "cc-flink-region" {
  cloud   = "AWS"
  region  = var.aws_region
}

locals {
  ksql_basic_auth_user_info= "${confluent_api_key.app-ksqldb-api-key.id}:${confluent_api_key.app-ksqldb-api-key.secret}"
}

provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

resource "confluent_schema" "avro-user-game" {
  schema_registry_cluster {
    id = confluent_schema_registry_cluster.essentials.id
  }
  rest_endpoint = confluent_schema_registry_cluster.essentials.rest_endpoint
  subject_name = "USER_GAME-value"
  format = "AVRO"
  schema = file("./functions/src/main/resources/avro/com/gnatali/streaming/games/avro/user_game.avsc")
  credentials {
    key = confluent_api_key.sr_cluster_key.id
    secret = confluent_api_key.sr_cluster_key.secret
  }
}

resource "confluent_schema" "avro-user-losses" {
  schema_registry_cluster {
    id = confluent_schema_registry_cluster.essentials.id
  }
  rest_endpoint = confluent_schema_registry_cluster.essentials.rest_endpoint
  subject_name = "USER_LOSSES-value"
  format = "AVRO"
  schema = file("./functions/src/main/resources/avro/com/gnatali/streaming/games/avro/user_losses.avsc")
  credentials {
    key = confluent_api_key.sr_cluster_key.id
    secret = confluent_api_key.sr_cluster_key.secret
  }
}

resource "confluent_environment" "staging" {
  display_name = local.resource_prefix
}

data "confluent_schema_registry_region" "essentials" {
  cloud   = "AWS"
  region  = var.schema_registry_region
  package = "ESSENTIALS"
}

resource "confluent_schema_registry_cluster" "essentials" {
  package = data.confluent_schema_registry_region.essentials.package

  environment {
    id = confluent_environment.staging.id
  }

  region {
    # See https://docs.confluent.io/cloud/current/stream-governance/packages.html#stream-governance-regions
    # Stream Governance and Kafka clusters can be in different regions as well as different cloud providers,
    # but you should to place both in the same cloud and region to restrict the fault isolation boundary.
    id = data.confluent_schema_registry_region.essentials.id
  }
}

# Update the config to use a cloud provider and region of your choice.
# https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/resources/confluent_kafka_cluster
resource "confluent_kafka_cluster" "games-demo" {
  display_name = "${local.resource_prefix}"
  availability = "SINGLE_ZONE"
  cloud        = "AWS"
  region       = var.aws_region
  basic {}
  environment {
    id = confluent_environment.staging.id
  }
}


// 'app-manager' service account is required in this configuration to grant ACLs
// to 'app-ksql' service account and create 'USER_GAME' and 'USER_LOSSES' topics
resource "confluent_service_account" "app-manager" {
  display_name = "${local.resource_prefix}-app-manager"
  description  = "Service account to manage 'inventory' Kafka cluster"
}

resource "confluent_role_binding" "app-manager-kafka-cluster-admin" {
  principal   = "User:${confluent_service_account.app-manager.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.games-demo.rbac_crn
}

resource "confluent_api_key" "app-manager-kafka-api-key" {
  display_name = "app-manager-kafka-api-key"
  description  = "Kafka API Key that is owned by 'app-manager' service account"
  owner {
    id          = confluent_service_account.app-manager.id
    api_version = confluent_service_account.app-manager.api_version
    kind        = confluent_service_account.app-manager.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.games-demo.id
    api_version = confluent_kafka_cluster.games-demo.api_version
    kind        = confluent_kafka_cluster.games-demo.kind

    environment {
      id = confluent_environment.staging.id
    }
  }

  # The goal is to ensure that confluent_role_binding.app-manager-kafka-cluster-admin is created before
  # confluent_api_key.app-manager-kafka-api-key is used to create instances of
  # confluent_kafka_topic, confluent_kafka_acl resources.

  # 'depends_on' meta-argument is specified in confluent_api_key.app-manager-kafka-api-key to avoid having
  # multiple copies of this definition in the configuration which would happen if we specify it in
  # confluent_kafka_topic, confluent_kafka_acl resources instead.
  depends_on = [
    confluent_role_binding.app-manager-kafka-cluster-admin
  ]
}

resource "confluent_kafka_topic" "user_game" {
  kafka_cluster {
    id = confluent_kafka_cluster.games-demo.id
  }
  topic_name    = "USER_GAME"
  partitions_count   = 1
  rest_endpoint = confluent_kafka_cluster.games-demo.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}

resource "confluent_kafka_topic" "user_losses" {
  kafka_cluster {
    id = confluent_kafka_cluster.games-demo.id
  }
  topic_name    = "USER_LOSSES"
  partitions_count   = 1
  rest_endpoint = confluent_kafka_cluster.games-demo.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}

// ksqlDB service account with only the necessary access
resource "confluent_service_account" "app-ksql" {
  display_name = "${local.resource_prefix}-app-ksql"
  description  = "Service account for Ksql cluster"
}

resource "confluent_ksql_cluster" "main" {
  display_name = "ksql_cluster_0"
  csu = 1
  kafka_cluster {
    id = confluent_kafka_cluster.games-demo.id
  }
  credential_identity {
    id = confluent_service_account.app-ksql.id
  }
  environment {
    id = confluent_environment.staging.id
  }

  depends_on = [
    confluent_schema_registry_cluster.essentials,
    confluent_role_binding.app-ksql-schema-registry-resource-owner
  ]
}

resource "confluent_kafka_acl" "app-ksql-describe-on-cluster" {
  kafka_cluster {
    id = confluent_kafka_cluster.games-demo.id
  }
  resource_type = "CLUSTER"
  resource_name = "kafka-cluster"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.app-ksql.id}"
  host          = "*"
  operation     = "DESCRIBE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.games-demo.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}

resource "confluent_kafka_acl" "app-ksql-describe-on-topic" {
  kafka_cluster {
    id = confluent_kafka_cluster.games-demo.id
  }
  resource_type = "TOPIC"
  resource_name = "*"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.app-ksql.id}"
  host          = "*"
  operation     = "DESCRIBE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.games-demo.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}

resource "confluent_kafka_acl" "app-ksql-describe-on-group" {
  kafka_cluster {
    id = confluent_kafka_cluster.games-demo.id
  }
  resource_type = "GROUP"
  resource_name = "*"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.app-ksql.id}"
  host          = "*"
  operation     = "DESCRIBE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.games-demo.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}

resource "confluent_kafka_acl" "app-ksql-describe-configs-on-cluster" {
  kafka_cluster {
    id = confluent_kafka_cluster.games-demo.id
  }
  resource_type = "CLUSTER"
  resource_name = "kafka-cluster"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.app-ksql.id}"
  host          = "*"
  operation     = "DESCRIBE_CONFIGS"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.games-demo.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}

resource "confluent_kafka_acl" "app-ksql-describe-configs-on-topic" {
  kafka_cluster {
    id = confluent_kafka_cluster.games-demo.id
  }
  resource_type = "TOPIC"
  resource_name = "*"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.app-ksql.id}"
  host          = "*"
  operation     = "DESCRIBE_CONFIGS"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.games-demo.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}

resource "confluent_kafka_acl" "app-ksql-describe-configs-on-group" {
  kafka_cluster {
    id = confluent_kafka_cluster.games-demo.id
  }
  resource_type = "GROUP"
  resource_name = "*"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.app-ksql.id}"
  host          = "*"
  operation     = "DESCRIBE_CONFIGS"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.games-demo.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}

resource "confluent_kafka_acl" "app-ksql-describe-on-transactional-id" {
  kafka_cluster {
    id = confluent_kafka_cluster.games-demo.id
  }
  resource_type = "TRANSACTIONAL_ID"
  resource_name = confluent_ksql_cluster.main.topic_prefix
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.app-ksql.id}"
  host          = "*"
  operation     = "DESCRIBE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.games-demo.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}

resource "confluent_kafka_acl" "app-ksql-write-on-transactional-id" {
  kafka_cluster {
    id = confluent_kafka_cluster.games-demo.id
  }
  resource_type = "TRANSACTIONAL_ID"
  resource_name = confluent_ksql_cluster.main.topic_prefix
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.app-ksql.id}"
  host          = "*"
  operation     = "WRITE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.games-demo.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}

resource "confluent_kafka_acl" "app-ksql-all-on-topic-prefix" {
  kafka_cluster {
    id = confluent_kafka_cluster.games-demo.id
  }
  resource_type = "TOPIC"
  resource_name = confluent_ksql_cluster.main.topic_prefix
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.app-ksql.id}"
  host          = "*"
  operation     = "ALL"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.games-demo.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}

resource "confluent_kafka_acl" "app-ksql-all-on-topic-confluent" {
  kafka_cluster {
    id = confluent_kafka_cluster.games-demo.id
  }
  resource_type = "TOPIC"
  resource_name = "_confluent-ksql-${confluent_ksql_cluster.main.topic_prefix}"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.app-ksql.id}"
  host          = "*"
  operation     = "ALL"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.games-demo.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}

resource "confluent_kafka_acl" "app-ksql-all-on-group-confluent" {
  kafka_cluster {
    id = confluent_kafka_cluster.games-demo.id
  }
  resource_type = "GROUP"
  resource_name = "_confluent-ksql-${confluent_ksql_cluster.main.topic_prefix}"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.app-ksql.id}"
  host          = "*"
  operation     = "ALL"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.games-demo.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}

# Topic specific permissions. You have to add an ACL like this for every Kafka topic you work with.
resource "confluent_kafka_acl" "app-ksql-all-on-topic-ug" {
  kafka_cluster {
    id = confluent_kafka_cluster.games-demo.id
  }
  resource_type = "TOPIC"
  resource_name = confluent_kafka_topic.user_game.topic_name
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.app-ksql.id}"
  host          = "*"
  operation     = "ALL"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.games-demo.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}

resource "confluent_kafka_acl" "app-ksql-all-on-topic-us" {
  kafka_cluster {
    id = confluent_kafka_cluster.games-demo.id
  }
  resource_type = "TOPIC"
  resource_name = confluent_kafka_topic.user_losses.topic_name
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.app-ksql.id}"
  host          = "*"
  operation     = "ALL"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.games-demo.rest_endpoint
  credentials {
    key    = confluent_api_key.app-manager-kafka-api-key.id
    secret = confluent_api_key.app-manager-kafka-api-key.secret
  }
}

resource "confluent_role_binding" "app-ksql-schema-registry-resource-owner" {
  principal   = "User:${confluent_service_account.app-ksql.id}"
  role_name   = "ResourceOwner"
  crn_pattern = format("%s/%s", confluent_schema_registry_cluster.essentials.resource_name, "subject=*")
}

# ACLs are needed for KSQL service account to read/write data from/to kafka, this role instead is needed for giving
# access to the Ksql cluster.
resource "confluent_role_binding" "app-ksql-ksql-admin" {
  principal   = "User:${confluent_service_account.app-ksql.id}"
  #role_name   = "KsqlAdmin"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.games-demo.rbac_crn
}

resource "confluent_api_key" "app-ksqldb-api-key" {
  display_name = "app-ksqldb-api-key"
  description  = "KsqlDB API Key that is owned by 'app-ksql' service account"
  owner {
    id          = confluent_service_account.app-ksql.id
    api_version = confluent_service_account.app-ksql.api_version
    kind        = confluent_service_account.app-ksql.kind
  }

  managed_resource {
    id          = confluent_ksql_cluster.main.id
    api_version = confluent_ksql_cluster.main.api_version
    kind        = confluent_ksql_cluster.main.kind

    environment {
      id = confluent_environment.staging.id
    }
  }
}


resource "confluent_service_account" "sr" {
  display_name = "${local.resource_prefix}-sr-manager"
  description  = "Service account to manage SR"
}

resource "confluent_role_binding" "sr_environment_admin" {
  principal   = "User:${confluent_service_account.sr.id}"
  role_name   = "EnvironmentAdmin"
  crn_pattern = confluent_environment.staging.resource_name
}

resource "confluent_api_key" "sr_cluster_key" {
  display_name = "sr-key"
  description  = "key for SR"
  owner {
    id          = confluent_service_account.sr.id
    api_version = confluent_service_account.sr.api_version
    kind        = confluent_service_account.sr.kind
  }
  managed_resource {
    id          = confluent_schema_registry_cluster.essentials.id
    api_version = confluent_schema_registry_cluster.essentials.api_version
    kind        = confluent_schema_registry_cluster.essentials.kind
    environment {
      id = confluent_environment.staging.id
    }
  }
  depends_on = [
    confluent_role_binding.sr_environment_admin
  ]
  lifecycle {
    prevent_destroy = false
  }
}

# --------------------------------------------------------
# Flink Compute Pool
# --------------------------------------------------------
resource "confluent_flink_compute_pool" "cc_flink_compute_pool" {
  display_name = "cc-flink-compute-pool"
  cloud        = "AWS"
  region       = var.aws_region
  max_cfu      = 5
  environment {
    id = confluent_environment.staging.id
  }
  depends_on = [
    confluent_kafka_cluster.games-demo
  ]
  lifecycle {
    prevent_destroy = false
  }
}

# --------------------------------------------------------
# Role Bindings added for Flink
# --------------------------------------------------------
resource "confluent_role_binding" "app-manager_environment_admin" {
  principal   = "User:${confluent_service_account.app-manager.id}"
  role_name   = "EnvironmentAdmin"
  crn_pattern = confluent_environment.staging.resource_name
  lifecycle {
    prevent_destroy = false
  }
}
resource "confluent_role_binding" "app-manager_flinkdeveloper" {
  principal   = "User:${confluent_service_account.app-manager.id}"
  role_name   = "FlinkDeveloper"
  crn_pattern = confluent_environment.staging.resource_name
  lifecycle {
    prevent_destroy = false
  }
}
resource "confluent_role_binding" "app-manager_flinkadmin" {
  principal   = "User:${confluent_service_account.app-manager.id}"
  role_name   = "FlinkAdmin"
  crn_pattern = confluent_environment.staging.resource_name
  lifecycle {
    prevent_destroy = false
  }
}
resource "confluent_role_binding" "app-manager_assigner" {
  principal   = "User:${confluent_service_account.app-manager.id}"
  role_name   = "Assigner"
  crn_pattern = "${data.confluent_organization.ccloud.resource_name}/service-account=${confluent_service_account.app-manager.id}"
  lifecycle {
    prevent_destroy = false
  }
}

# --------------------------------------------------------
# Flink API Keys
# --------------------------------------------------------
resource "confluent_api_key" "env-manager-flink-api-key" {
  display_name = "env-manager-flink-api-key"
  description  = "Flink API Key that is owned by 'env-manager' service account"
  owner {
    id          = confluent_service_account.app-manager.id
    api_version = confluent_service_account.app-manager.api_version
    kind        = confluent_service_account.app-manager.kind
  }

  managed_resource {
    id          = "aws.${var.aws_region}"
    api_version = "fcpm/v2"
    kind        = "Region"

    environment {
      id = confluent_environment.staging.id
    }
  }

  lifecycle {
    prevent_destroy = false
  }
}

