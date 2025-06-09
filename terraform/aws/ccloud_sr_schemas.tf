# resource "confluent_schema" "avro-user-game" {
#   schema_registry_cluster {
#     id = data.confluent_schema_registry_cluster.essentials.id
#   }
#   rest_endpoint = module.terrasnap_solution.confluent_cloud_0_schema_registry_rest_endpoint
#   subject_name = "USER_GAME-value"
#   format = "AVRO"
#   schema = file("./functions/src/main/resources/avro/com/gnatali/streaming/games/avro/user_game.avsc")
#   credentials {
#     key = module.terrasnap_solution.confluent_cloud_0_schema_registry_api_key
#     secret = module.terrasnap_solution.confluent_cloud_0_schema_registry_api_secret
#   }
# }

# resource "confluent_schema" "avro-user-losses" {
#   schema_registry_cluster {
#     id = data.confluent_schema_registry_cluster.essentials.id
#   }
#   rest_endpoint = data.confluent_schema_registry_cluster.essentials.rest_endpoint
#   subject_name = "USER_LOSSES-value"
#   format = "AVRO"
#   schema = file("./functions/src/main/resources/avro/com/gnatali/streaming/games/avro/user_losses.avsc")
#   credentials {
#     key = module.terrasnap_solution.confluent_cloud_0_schema_registry_api_key
#     secret = module.terrasnap_solution.confluent_cloud_0_schema_registry_api_secret
#   }
# }