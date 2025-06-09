# Confluent Cloud Topic

The module create a topic.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_confluent"></a> [confluent](#requirement\_confluent) | 2.23.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_confluent"></a> [confluent](#provider\_confluent) | 2.23.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [confluent_kafka_topic.topic](https://registry.terraform.io/providers/confluentinc/confluent/2.23.0/docs/resources/kafka_topic) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_confluent_cloud_api_key"></a> [confluent\_cloud\_api\_key](#input\_confluent\_cloud\_api\_key) | Confluent Cloud API Key | `string` | n/a | yes |
| <a name="input_confluent_cloud_api_secret"></a> [confluent\_cloud\_api\_secret](#input\_confluent\_cloud\_api\_secret) | Confluent Cloud API Secret | `string` | n/a | yes |
| <a name="input_confluent_cloud_cluster_id"></a> [confluent\_cloud\_cluster\_id](#input\_confluent\_cloud\_cluster\_id) | Confluent Cloud Cluster ID | `string` | n/a | yes |
| <a name="input_confluent_cloud_cluster_key"></a> [confluent\_cloud\_cluster\_key](#input\_confluent\_cloud\_cluster\_key) | Confluent Cloud API Key | `string` | n/a | yes |
| <a name="input_confluent_cloud_cluster_rest_endpoint"></a> [confluent\_cloud\_cluster\_rest\_endpoint](#input\_confluent\_cloud\_cluster\_rest\_endpoint) | Confluent Cloud Cluster REST Endpoint | `string` | n/a | yes |
| <a name="input_confluent_cloud_cluster_secret"></a> [confluent\_cloud\_cluster\_secret](#input\_confluent\_cloud\_cluster\_secret) | Confluent Cloud API Secret | `string` | n/a | yes |
| <a name="input_partitions_count"></a> [partitions\_count](#input\_partitions\_count) | Number of partitions for the topic | `number` | n/a | yes |
| <a name="input_topic_name"></a> [topic\_name](#input\_topic\_name) | Name of the topic | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
