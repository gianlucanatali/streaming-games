# Confluent Cloud Flink Statement Executor

This module executes Flink statements, in a given order, against a Flink Compute pool.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_confluent"></a> [confluent](#requirement\_confluent) | 2.23.0 |
| <a name="requirement_docker"></a> [docker](#requirement\_docker) | 3.0.2 |
| <a name="requirement_null"></a> [null](#requirement\_null) | 3.2.4 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.7.2 |
| <a name="requirement_time"></a> [time](#requirement\_time) | 0.13.1-alpha1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_confluent"></a> [confluent](#provider\_confluent) | 2.23.0 |
| <a name="provider_docker"></a> [docker](#provider\_docker) | 3.0.2 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.4 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.2 |
| <a name="provider_time"></a> [time](#provider\_time) | 0.13.1-alpha1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [docker_container.builder](https://registry.terraform.io/providers/kreuzwerker/docker/3.0.2/docs/resources/container) | resource |
| [docker_container.terrasnap_flink_statement_executor](https://registry.terraform.io/providers/kreuzwerker/docker/3.0.2/docs/resources/container) | resource |
| [docker_image.builder](https://registry.terraform.io/providers/kreuzwerker/docker/3.0.2/docs/resources/image) | resource |
| [docker_image.terrasnap_flink_statement_executor](https://registry.terraform.io/providers/kreuzwerker/docker/3.0.2/docs/resources/image) | resource |
| [null_resource.wait_for_flink_executions](https://registry.terraform.io/providers/hashicorp/null/3.2.4/docs/resources/resource) | resource |
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/3.7.2/docs/resources/string) | resource |
| [time_sleep.wait_for_binary_compile](https://registry.terraform.io/providers/hashicorp/time/0.13.1-alpha1/docs/resources/sleep) | resource |
| [confluent_environment.this](https://registry.terraform.io/providers/confluentinc/confluent/2.23.0/docs/data-sources/environment) | data source |
| [confluent_kafka_cluster.this](https://registry.terraform.io/providers/confluentinc/confluent/2.23.0/docs/data-sources/kafka_cluster) | data source |
| [confluent_organization.main](https://registry.terraform.io/providers/confluentinc/confluent/2.23.0/docs/data-sources/organization) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_confluent_cloud_api_key"></a> [confluent\_cloud\_api\_key](#input\_confluent\_cloud\_api\_key) | Confluent Cloud API Key (also referred as Cloud API ID) | `string` | n/a | yes |
| <a name="input_confluent_cloud_api_secret"></a> [confluent\_cloud\_api\_secret](#input\_confluent\_cloud\_api\_secret) | Confluent Cloud API Secret | `string` | n/a | yes |
| <a name="input_confluent_cloud_cluster_id"></a> [confluent\_cloud\_cluster\_id](#input\_confluent\_cloud\_cluster\_id) | Confluent Cloud cluster ID. | `string` | n/a | yes |
| <a name="input_confluent_cloud_environment_flink_api_key"></a> [confluent\_cloud\_environment\_flink\_api\_key](#input\_confluent\_cloud\_environment\_flink\_api\_key) | Confluent Cloud Flink API key. | `string` | n/a | yes |
| <a name="input_confluent_cloud_environment_flink_api_secret"></a> [confluent\_cloud\_environment\_flink\_api\_secret](#input\_confluent\_cloud\_environment\_flink\_api\_secret) | Confluent Cloud Flink API secret. | `string` | n/a | yes |
| <a name="input_confluent_cloud_environment_id"></a> [confluent\_cloud\_environment\_id](#input\_confluent\_cloud\_environment\_id) | Confluent Cloud environment ID. | `string` | n/a | yes |
| <a name="input_confluent_cloud_service_account_id"></a> [confluent\_cloud\_service\_account\_id](#input\_confluent\_cloud\_service\_account\_id) | Confluent Cloud environment app manager service account ID. | `string` | n/a | yes |
| <a name="input_flink_compute_pool_id"></a> [flink\_compute\_pool\_id](#input\_flink\_compute\_pool\_id) | Confluent Cloud Flink compute pool ID. | `string` | n/a | yes |
| <a name="input_flink_statements"></a> [flink\_statements](#input\_flink\_statements) | Flink statement that registers the AI model in the Flink workspace. | `list(string)` | <pre>[<br/>  ""<br/>]</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
