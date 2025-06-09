# Confluent Cloud Flink Compute Pool

This module creates a new Flink compute pool.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_confluent"></a> [confluent](#requirement\_confluent) | 2.23.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.7.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_confluent"></a> [confluent](#provider\_confluent) | 2.23.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [confluent_flink_compute_pool.flink_pool](https://registry.terraform.io/providers/confluentinc/confluent/2.23.0/docs/resources/flink_compute_pool) | resource |
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/3.7.2/docs/resources/string) | resource |
| [confluent_kafka_cluster.this](https://registry.terraform.io/providers/confluentinc/confluent/2.23.0/docs/data-sources/kafka_cluster) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_confluent_cloud_api_key"></a> [confluent\_cloud\_api\_key](#input\_confluent\_cloud\_api\_key) | Confluent Cloud API Key (also referred as Cloud API ID) | `string` | n/a | yes |
| <a name="input_confluent_cloud_api_secret"></a> [confluent\_cloud\_api\_secret](#input\_confluent\_cloud\_api\_secret) | Confluent Cloud API Secret | `string` | n/a | yes |
| <a name="input_confluent_cloud_cluster_id"></a> [confluent\_cloud\_cluster\_id](#input\_confluent\_cloud\_cluster\_id) | Confluent Cloud cluster ID. | `string` | n/a | yes |
| <a name="input_confluent_cloud_environment_id"></a> [confluent\_cloud\_environment\_id](#input\_confluent\_cloud\_environment\_id) | Confluent Cloud environment ID. | `string` | n/a | yes |
| <a name="input_flink_compute_pool_name"></a> [flink\_compute\_pool\_name](#input\_flink\_compute\_pool\_name) | Flink compute pool name. | `string` | n/a | yes |
| <a name="input_flink_max_cfu"></a> [flink\_max\_cfu](#input\_flink\_max\_cfu) | Maximum number of Confluent Flink Units (CFUs) that the Flink compute pool should auto-scale to. | `number` | `10` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_flink_compute_pool_id"></a> [flink\_compute\_pool\_id](#output\_flink\_compute\_pool\_id) | n/a |
| <a name="output_flink_compute_pool_name"></a> [flink\_compute\_pool\_name](#output\_flink\_compute\_pool\_name) | n/a |
<!-- END_TF_DOCS -->
