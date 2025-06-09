// 'app-manager' service account is required in this configuration to grant ACLs
// to 'app-ksql' service account and create 'USER_GAME' and 'USER_LOSSES' topics
resource "confluent_service_account" "app-manager" {
  display_name = "${local.resource_prefix}-app-manager"
  description  = "Service account to manage 'inventory' Kafka cluster"
}

resource "confluent_role_binding" "app-manager-kafka-cluster-admin" {
  principal   = "User:${confluent_service_account.app-manager.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = module.terrasnap_solution.confluent_cloud_0_cluster_rbac_crn
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
    id = module.terrasnap_solution.confluent_cloud_0_cluster_id
  }
  credential_identity {
    id = confluent_service_account.app-ksql.id
  }
  environment {
    id = module.terrasnap_solution.confluent_cloud_0_environment_id
  }

  depends_on = [
    confluent_role_binding.app-ksql-schema-registry-resource-owner
  ]
}

resource "confluent_kafka_acl" "app-ksql-describe-on-cluster" {
  kafka_cluster {
    id = module.terrasnap_solution.confluent_cloud_0_cluster_id
  }
  resource_type = "CLUSTER"
  resource_name = "kafka-cluster"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.app-ksql.id}"
  host          = "*"
  operation     = "DESCRIBE"
  permission    = "ALLOW"
  rest_endpoint = module.terrasnap_solution.confluent_cloud_0_cluster_rest_endpoint
  credentials {
    key    = module.terrasnap_solution.confluent_cloud_0_cluster_key
    secret = module.terrasnap_solution.confluent_cloud_0_cluster_secret
  }
}

resource "confluent_kafka_acl" "app-ksql-describe-on-topic" {
  kafka_cluster {
    id = module.terrasnap_solution.confluent_cloud_0_cluster_id
  }
  resource_type = "TOPIC"
  resource_name = "*"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.app-ksql.id}"
  host          = "*"
  operation     = "DESCRIBE"
  permission    = "ALLOW"
  rest_endpoint = module.terrasnap_solution.confluent_cloud_0_cluster_rest_endpoint
  credentials {
    key    = module.terrasnap_solution.confluent_cloud_0_cluster_key
    secret = module.terrasnap_solution.confluent_cloud_0_cluster_secret
  }
}

resource "confluent_kafka_acl" "app-ksql-describe-on-group" {
  kafka_cluster {
    id = module.terrasnap_solution.confluent_cloud_0_cluster_id
  }
  resource_type = "GROUP"
  resource_name = "*"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.app-ksql.id}"
  host          = "*"
  operation     = "DESCRIBE"
  permission    = "ALLOW"
  rest_endpoint = module.terrasnap_solution.confluent_cloud_0_cluster_rest_endpoint
  credentials {
    key    = module.terrasnap_solution.confluent_cloud_0_cluster_key
    secret = module.terrasnap_solution.confluent_cloud_0_cluster_secret
  }
}

resource "confluent_kafka_acl" "app-ksql-describe-configs-on-cluster" {
  kafka_cluster {
    id = module.terrasnap_solution.confluent_cloud_0_cluster_id
  }
  resource_type = "CLUSTER"
  resource_name = "kafka-cluster"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.app-ksql.id}"
  host          = "*"
  operation     = "DESCRIBE_CONFIGS"
  permission    = "ALLOW"
  rest_endpoint = module.terrasnap_solution.confluent_cloud_0_cluster_rest_endpoint
  credentials {
    key    = module.terrasnap_solution.confluent_cloud_0_cluster_key
    secret = module.terrasnap_solution.confluent_cloud_0_cluster_secret
  }
}

resource "confluent_kafka_acl" "app-ksql-describe-configs-on-topic" {
  kafka_cluster {
    id = module.terrasnap_solution.confluent_cloud_0_cluster_id
  }
  resource_type = "TOPIC"
  resource_name = "*"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.app-ksql.id}"
  host          = "*"
  operation     = "DESCRIBE_CONFIGS"
  permission    = "ALLOW"
  rest_endpoint = module.terrasnap_solution.confluent_cloud_0_cluster_rest_endpoint
  credentials {
    key    = module.terrasnap_solution.confluent_cloud_0_cluster_key
    secret = module.terrasnap_solution.confluent_cloud_0_cluster_secret
  }
}

resource "confluent_kafka_acl" "app-ksql-describe-configs-on-group" {
  kafka_cluster {
    id = module.terrasnap_solution.confluent_cloud_0_cluster_id
  }
  resource_type = "GROUP"
  resource_name = "*"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.app-ksql.id}"
  host          = "*"
  operation     = "DESCRIBE_CONFIGS"
  permission    = "ALLOW"
  rest_endpoint = module.terrasnap_solution.confluent_cloud_0_cluster_rest_endpoint
  credentials {
    key    = module.terrasnap_solution.confluent_cloud_0_cluster_key
    secret = module.terrasnap_solution.confluent_cloud_0_cluster_secret
  }
}

resource "confluent_kafka_acl" "app-ksql-describe-on-transactional-id" {
  kafka_cluster {
    id = module.terrasnap_solution.confluent_cloud_0_cluster_id
  }
  resource_type = "TRANSACTIONAL_ID"
  resource_name = confluent_ksql_cluster.main.topic_prefix
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.app-ksql.id}"
  host          = "*"
  operation     = "DESCRIBE"
  permission    = "ALLOW"
  rest_endpoint = module.terrasnap_solution.confluent_cloud_0_cluster_rest_endpoint
  credentials {
    key    = module.terrasnap_solution.confluent_cloud_0_cluster_key
    secret = module.terrasnap_solution.confluent_cloud_0_cluster_secret
  }
}

resource "confluent_kafka_acl" "app-ksql-write-on-transactional-id" {
  kafka_cluster {
    id = module.terrasnap_solution.confluent_cloud_0_cluster_id
  }
  resource_type = "TRANSACTIONAL_ID"
  resource_name = confluent_ksql_cluster.main.topic_prefix
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.app-ksql.id}"
  host          = "*"
  operation     = "WRITE"
  permission    = "ALLOW"
  rest_endpoint = module.terrasnap_solution.confluent_cloud_0_cluster_rest_endpoint
  credentials {
    key    = module.terrasnap_solution.confluent_cloud_0_cluster_key
    secret = module.terrasnap_solution.confluent_cloud_0_cluster_secret
  }
}

resource "confluent_kafka_acl" "app-ksql-all-on-topic-prefix" {
  kafka_cluster {
    id = module.terrasnap_solution.confluent_cloud_0_cluster_id
  }
  resource_type = "TOPIC"
  resource_name = confluent_ksql_cluster.main.topic_prefix
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.app-ksql.id}"
  host          = "*"
  operation     = "ALL"
  permission    = "ALLOW"
  rest_endpoint = module.terrasnap_solution.confluent_cloud_0_cluster_rest_endpoint
  credentials {
    key    = module.terrasnap_solution.confluent_cloud_0_cluster_key
    secret = module.terrasnap_solution.confluent_cloud_0_cluster_secret
  }
}

resource "confluent_kafka_acl" "app-ksql-all-on-topic-confluent" {
  kafka_cluster {
    id = module.terrasnap_solution.confluent_cloud_0_cluster_id
  }
  resource_type = "TOPIC"
  resource_name = "_confluent-ksql-${confluent_ksql_cluster.main.topic_prefix}"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.app-ksql.id}"
  host          = "*"
  operation     = "ALL"
  permission    = "ALLOW"
  rest_endpoint = module.terrasnap_solution.confluent_cloud_0_cluster_rest_endpoint
  credentials {
    key    = module.terrasnap_solution.confluent_cloud_0_cluster_key
    secret = module.terrasnap_solution.confluent_cloud_0_cluster_secret
  }
}

resource "confluent_kafka_acl" "app-ksql-all-on-group-confluent" {
  kafka_cluster {
    id = module.terrasnap_solution.confluent_cloud_0_cluster_id
  }
  resource_type = "GROUP"
  resource_name = "_confluent-ksql-${confluent_ksql_cluster.main.topic_prefix}"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.app-ksql.id}"
  host          = "*"
  operation     = "ALL"
  permission    = "ALLOW"
  rest_endpoint = module.terrasnap_solution.confluent_cloud_0_cluster_rest_endpoint
  credentials {
    key    = module.terrasnap_solution.confluent_cloud_0_cluster_key
    secret = module.terrasnap_solution.confluent_cloud_0_cluster_secret
  }
}

# Topic specific permissions. You have to add an ACL like this for every Kafka topic you work with.
resource "confluent_kafka_acl" "app-ksql-all-on-topic-ug" {
  kafka_cluster {
    id = module.terrasnap_solution.confluent_cloud_0_cluster_id
  }
  resource_type = "TOPIC"
  resource_name = "USER_GAME"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.app-ksql.id}"
  host          = "*"
  operation     = "ALL"
  permission    = "ALLOW"
  rest_endpoint = module.terrasnap_solution.confluent_cloud_0_cluster_rest_endpoint
  credentials {
    key    = module.terrasnap_solution.confluent_cloud_0_cluster_key
    secret = module.terrasnap_solution.confluent_cloud_0_cluster_secret
  }
}

resource "confluent_kafka_acl" "app-ksql-all-on-topic-us" {
  kafka_cluster {
    id = module.terrasnap_solution.confluent_cloud_0_cluster_id
  }
  resource_type = "TOPIC"
  resource_name = "USER_LOSSES"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.app-ksql.id}"
  host          = "*"
  operation     = "ALL"
  permission    = "ALLOW"
  rest_endpoint = module.terrasnap_solution.confluent_cloud_0_cluster_rest_endpoint
  credentials {
    key    = module.terrasnap_solution.confluent_cloud_0_cluster_key
    secret = module.terrasnap_solution.confluent_cloud_0_cluster_secret
  }
}

resource "confluent_role_binding" "app-ksql-schema-registry-resource-owner" {
  principal   = "User:${confluent_service_account.app-ksql.id}"
  role_name   = "ResourceOwner"
  crn_pattern = format("%s/%s", module.terrasnap_solution.confluent_cloud_0_schema_registry_resource_name, "subject=*")
}

# ACLs are needed for KSQL service account to read/write data from/to kafka, this role instead is needed for giving
# access to the Ksql cluster.
resource "confluent_role_binding" "app-ksql-ksql-admin" {
  principal   = "User:${confluent_service_account.app-ksql.id}"
  #role_name   = "KsqlAdmin"
  role_name   = "CloudClusterAdmin"
  crn_pattern = module.terrasnap_solution.confluent_cloud_0_cluster_rbac_crn
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
      id = module.terrasnap_solution.confluent_cloud_0_environment_id
    }
  }
}