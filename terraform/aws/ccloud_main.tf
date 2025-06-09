terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "2.23.0"
    }
  }
}

locals {
  ksql_basic_auth_user_info= "${confluent_api_key.app-ksqldb-api-key.id}:${confluent_api_key.app-ksqldb-api-key.secret}"
}

provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}


data "confluent_organization" "ccloud" {}

# resource "confluent_environment" "staging" {
#   display_name = local.resource_prefix

#   stream_governance { 
#     package = "ESSENTIALS"
#   }
# }

# data "confluent_schema_registry_cluster" "essentials" {
#   environment {
#     id = module.terrasnap_solution.confluent_cloud_0_environment_id
#   }

#   depends_on = [
#     module.terrasnap_solution
#   ]

  
# }


