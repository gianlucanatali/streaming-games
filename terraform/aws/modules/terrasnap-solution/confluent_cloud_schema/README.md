# Confluent Cloud Schema

This module manages Confluent Cloud Schema Registry schemas, allowing you to define and maintain Avro, JSON, or Protobuf schemas for your Kafka topics.

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
| [confluent_schema.schema](https://registry.terraform.io/providers/confluentinc/confluent/2.23.0/docs/resources/schema) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_confluent_cloud_api_key"></a> [confluent\_cloud\_api\_key](#input\_confluent\_cloud\_api\_key) | Confluent Cloud API Key | `string` | n/a | yes |
| <a name="input_confluent_cloud_api_secret"></a> [confluent\_cloud\_api\_secret](#input\_confluent\_cloud\_api\_secret) | Confluent Cloud API Secret | `string` | n/a | yes |
| <a name="input_confluent_cloud_schema_registry_api_key"></a> [confluent\_cloud\_schema\_registry\_api\_key](#input\_confluent\_cloud\_schema\_registry\_api\_key) | Confluent Cloud Schema Registry API Key | `string` | n/a | yes |
| <a name="input_confluent_cloud_schema_registry_api_secret"></a> [confluent\_cloud\_schema\_registry\_api\_secret](#input\_confluent\_cloud\_schema\_registry\_api\_secret) | Confluent Cloud Schema Registry API Secret | `string` | n/a | yes |
| <a name="input_confluent_cloud_schema_registry_id"></a> [confluent\_cloud\_schema\_registry\_id](#input\_confluent\_cloud\_schema\_registry\_id) | Confluent Cloud Schema Registry ID | `string` | n/a | yes |
| <a name="input_confluent_cloud_schema_registry_rest_endpoint"></a> [confluent\_cloud\_schema\_registry\_rest\_endpoint](#input\_confluent\_cloud\_schema\_registry\_rest\_endpoint) | Confluent Cloud Schema Registry REST Endpoint | `string` | n/a | yes |
| <a name="input_format"></a> [format](#input\_format) | Format | `string` | n/a | yes |
| <a name="input_schema_path"></a> [schema\_path](#input\_schema\_path) | Schema Path | `string` | n/a | yes |
| <a name="input_subject_name"></a> [subject\_name](#input\_subject\_name) | Subject Name | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
