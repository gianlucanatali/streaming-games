# --------------------------------------------------------
# Flink SQL: CREATE TABLE LOSSES_PER_USER
# --------------------------------------------------------
resource "confluent_flink_statement" "create_losses_per_user" {
  count = var.run_as_workshop ? 0 : 1
  depends_on = [
    resource.confluent_environment.staging,
    resource.confluent_schema_registry_cluster.essentials,
    resource.confluent_kafka_cluster.games-demo,
    resource.confluent_flink_compute_pool.cc_flink_compute_pool,
    resource.confluent_schema.avro-user-losses
  ]
  organization {
    id = data.confluent_organization.ccloud.id
  } 
  environment {
    id = confluent_environment.staging.id
  }
  compute_pool {
    id = confluent_flink_compute_pool.cc_flink_compute_pool.id
  }
  principal {
    id = confluent_service_account.app-manager.id
  }
  statement  = "CREATE TABLE LOSSES_PER_USER (`USER` STRING,`GAME_NAME` STRING,`TOTAL_LOSSES` INT, PRIMARY KEY (`USER`, `GAME_NAME`) NOT ENFORCED) WITH ('kafka.partitions' = '1');"
  properties = {
    "sql.current-catalog"  = confluent_environment.staging.display_name
    "sql.current-database" = confluent_kafka_cluster.games-demo.display_name
  }
  rest_endpoint   =  data.confluent_flink_region.cc-flink-region.rest_endpoint
  credentials {
    key    = confluent_api_key.env-manager-flink-api-key.id
    secret = confluent_api_key.env-manager-flink-api-key.secret
  }
  lifecycle {
    prevent_destroy = false
  }
}

# --------------------------------------------------------
# Flink SQL: INSERT INTO TABLE LOSSES_PER_USER
# --------------------------------------------------------
resource "confluent_flink_statement" "insert_losses_per_user" {
  count = var.run_as_workshop ? 0 : 1
  depends_on = [
    resource.confluent_flink_statement.create_losses_per_user
  ]
  organization {
    id = data.confluent_organization.ccloud.id
  } 
  environment {
    id = confluent_environment.staging.id
  }
  compute_pool {
    id = confluent_flink_compute_pool.cc_flink_compute_pool.id
  }
  principal {
    id = confluent_service_account.app-manager.id
  }
  statement  = "INSERT INTO LOSSES_PER_USER SELECT `user`, game_name, cast(count(game_name) as int) as total_losses FROM USER_LOSSES GROUP BY `user`,game_name;"
  properties = {
    "sql.current-catalog"  = confluent_environment.staging.display_name
    "sql.current-database" = confluent_kafka_cluster.games-demo.display_name
  }
  rest_endpoint   =   data.confluent_flink_region.cc-flink-region.rest_endpoint
  credentials {
    key    = confluent_api_key.env-manager-flink-api-key.id
    secret = confluent_api_key.env-manager-flink-api-key.secret
  }
  lifecycle {
    prevent_destroy = false
  }
}

# --------------------------------------------------------
# Flink SQL: CREATE TABLE STATS_PER_USER
# --------------------------------------------------------
resource "confluent_flink_statement" "create_stats_per_user" {
  count = var.run_as_workshop ? 0 : 1
  depends_on = [
    resource.confluent_environment.staging,
    resource.confluent_schema_registry_cluster.essentials,
    resource.confluent_kafka_cluster.games-demo,
    resource.confluent_flink_compute_pool.cc_flink_compute_pool,
    resource.confluent_flink_statement.insert_losses_per_user
  ]
  organization {
    id = data.confluent_organization.ccloud.id
  } 
  environment {
    id = confluent_environment.staging.id
  }
  compute_pool {
    id = confluent_flink_compute_pool.cc_flink_compute_pool.id
  }
  principal {
    id = confluent_service_account.app-manager.id
  }
  statement  = "CREATE TABLE STATS_PER_USER (`USER` STRING, `GAME_NAME` STRING, `HIGHEST_SCORE` INT, `HIGHEST_LEVEL` INT, `TOTAL_LOSSES` INT, PRIMARY KEY (`USER`, `GAME_NAME`) NOT ENFORCED) WITH ('kafka.partitions' = '1', 'kafka.cleanup-policy' = 'delete-compact');"
  properties = {
    "sql.current-catalog"  = confluent_environment.staging.display_name
    "sql.current-database" = confluent_kafka_cluster.games-demo.display_name
  }
  rest_endpoint   =   data.confluent_flink_region.cc-flink-region.rest_endpoint
  credentials {
    key    = confluent_api_key.env-manager-flink-api-key.id
    secret = confluent_api_key.env-manager-flink-api-key.secret
  }
  lifecycle {
    prevent_destroy = false
  }
}

# --------------------------------------------------------
# Flink SQL: INSERT INTO TABLE STATS_PER_USER
# --------------------------------------------------------
resource "confluent_flink_statement" "insert_stats_per_user" {
  count = var.run_as_workshop ? 0 : 1
  depends_on = [
    resource.confluent_flink_statement.create_stats_per_user
  ]
  organization {
    id = data.confluent_organization.ccloud.id
  } 
  environment {
    id = confluent_environment.staging.id
  }
  compute_pool {
    id = confluent_flink_compute_pool.cc_flink_compute_pool.id
  }
  principal {
    id = confluent_service_account.app-manager.id
  }
  statement  = "INSERT INTO STATS_PER_USER SELECT UG.`user` AS `USER`, UG.game_name AS GAME_NAME, MAX(UG.score) AS HIGHEST_SCORE, MAX(UG.level) AS HIGHEST_LEVEL, MAX(CASE WHEN LPU.TOTAL_LOSSES IS NULL THEN CAST (0 AS INT) ELSE LPU.TOTAL_LOSSES END) AS TOTAL_LOSSES FROM USER_GAME UG LEFT JOIN LOSSES_PER_USER LPU ON UG.`user` = LPU.`USER` AND UG.game_name = LPU.GAME_NAME GROUP BY UG.`user`, UG.game_name;"
  properties = {
    "sql.current-catalog"  = confluent_environment.staging.display_name
    "sql.current-database" = confluent_kafka_cluster.games-demo.display_name
  }
  rest_endpoint   =   data.confluent_flink_region.cc-flink-region.rest_endpoint
  credentials {
    key    = confluent_api_key.env-manager-flink-api-key.id
    secret = confluent_api_key.env-manager-flink-api-key.secret
  }
  lifecycle {
    prevent_destroy = false
  }
}

