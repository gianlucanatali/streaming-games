###########################################
############ Common Artifacts #############
###########################################

/*resource "null_resource" "build_functions" {
  #if you enable this will conflict with the hash checking on the lambda function
  # triggers = {
  #   always_run = "${timestamp()}"
  # }
  provisioner "local-exec" {
    command = "sh build.sh"
    interpreter = ["bash", "-c"]
    working_dir = "functions"
  }
}*/

locals {
  generic_wake_up = templatefile("functions/generic-wake-up.json", {
    cloud_provider = "AWS"
    ksqldb_endpoint = "${aws_api_gateway_deployment.event_handler_v1.invoke_url}${aws_api_gateway_resource.event_handler_resource.path}"
    ksql_basic_auth_user_info = local.ksql_basic_auth_user_info
    #TODO scoreboard_api = "${aws_api_gateway_deployment.scoreboard_v1.invoke_url}${aws_api_gateway_resource.scoreboard_resource.path}"
    scoreboard_api = ""
  })
}

###########################################
########### Event Handler API #############
###########################################

resource "aws_api_gateway_rest_api" "event_handler_api" {
  depends_on = [aws_lambda_function.event_handler_function]
  name = "${local.resource_prefix}_event_handler_api"
  description = "Event Handler API"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "event_handler_resource" {
  rest_api_id = aws_api_gateway_rest_api.event_handler_api.id
  parent_id = aws_api_gateway_rest_api.event_handler_api.root_resource_id
  path_part = "event"
}

resource "aws_api_gateway_method" "event_handler_post_method" {
  rest_api_id = aws_api_gateway_rest_api.event_handler_api.id
  resource_id = aws_api_gateway_resource.event_handler_resource.id
  http_method = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "event_handler_post_integration" {
  rest_api_id = aws_api_gateway_rest_api.event_handler_api.id
  resource_id = aws_api_gateway_resource.event_handler_resource.id
  http_method = aws_api_gateway_method.event_handler_post_method.http_method
  integration_http_method = aws_api_gateway_method.event_handler_post_method.http_method
  uri = aws_lambda_function.event_handler_function.invoke_arn
  type = "AWS_PROXY"
}

resource "aws_api_gateway_method_response" "event_handler_post_method_response" {
  rest_api_id = aws_api_gateway_rest_api.event_handler_api.id
  resource_id = aws_api_gateway_resource.event_handler_resource.id
  http_method = aws_api_gateway_method.event_handler_post_method.http_method
  status_code = "200"
}

resource "aws_api_gateway_deployment" "event_handler_v1" {
  depends_on = [aws_api_gateway_integration.event_handler_post_integration]
  rest_api_id = aws_api_gateway_rest_api.event_handler_api.id
}

resource "aws_api_gateway_stage" "event_handler_v1" {
  depends_on = [aws_api_gateway_account.demo]
  deployment_id = aws_api_gateway_deployment.event_handler_v1.id
  rest_api_id   = aws_api_gateway_rest_api.event_handler_api.id
  stage_name    = "api"
}

###########################################
########### Event Handler CORS ############
###########################################

resource "aws_api_gateway_method" "event_handler_options_method" {
  rest_api_id = aws_api_gateway_rest_api.event_handler_api.id
  resource_id = aws_api_gateway_resource.event_handler_resource.id
  http_method = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "event_handler_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.event_handler_api.id
  resource_id = aws_api_gateway_resource.event_handler_resource.id
  http_method = aws_api_gateway_method.event_handler_options_method.http_method
  type = "MOCK"
  request_templates = {
    "application/json" = <<EOF
{ "statusCode": 200 }
EOF
  }
}

resource "aws_api_gateway_method_response" "event_handler_options_method_response" {
  rest_api_id = aws_api_gateway_rest_api.event_handler_api.id
  resource_id = aws_api_gateway_resource.event_handler_resource.id
  http_method = aws_api_gateway_method.event_handler_options_method.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_method_settings" "event_handler_method_settings" {
  rest_api_id = "${aws_api_gateway_rest_api.event_handler_api.id}"
  stage_name  = "${aws_api_gateway_stage.event_handler_v1.stage_name}"
  method_path = "*/*"
  settings {
    logging_level = "INFO"
    data_trace_enabled = true
    metrics_enabled = true
  }
}


###########################################
######### Event Handler Function ##########
###########################################

resource "aws_api_gateway_account" "demo" {
  cloudwatch_role_arn = aws_iam_role.cloudwatch.arn
}

data "aws_iam_policy_document" "assume_role_api_gateway" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "cloudwatch" {
  name               = "${local.resource_prefix}_api_gateway_cloudwatch_global"
  assume_role_policy = data.aws_iam_policy_document.assume_role_api_gateway.json
}

data "aws_iam_policy_document" "cloudwatch" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents",
    ]

    resources = ["*"]
  }
}
resource "aws_iam_role_policy" "cloudwatch" {
  name   = "default"
  role   = aws_iam_role.cloudwatch.id
  policy = data.aws_iam_policy_document.cloudwatch.json
}

data "aws_iam_policy_document" "event_handler_role" {
  statement {
    effect    = "Allow"
    actions   = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        ]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = [
        "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath",
        ]
    resources = [
      aws_ssm_parameter.origin_allowed.arn
      ]
  }
}

data "aws_iam_policy_document" "assume_role_Lambda_Service" {
  statement  {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_policy" "event_handler_role" {
  name        = "${local.resource_prefix}_event-handler-policy"
  description = "A  policy for the event handler games"
  policy      = data.aws_iam_policy_document.event_handler_role.json
}

resource "aws_iam_policy_attachment" "event_handler_role" {
  name       = "${local.resource_prefix}_event_handler_role-attachment"
  roles      = [aws_iam_role.event_handler_role.name]
  policy_arn = aws_iam_policy.event_handler_role.arn
}

resource "aws_iam_role" "event_handler_role" {

  name = "${local.resource_prefix}_event_handler_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_Lambda_Service.json

}

resource "aws_ssm_parameter" "origin_allowed" {
  name  = "${local.ssm_parameter_name}" 
  type  = "String"
  value = "https://${aws_cloudfront_distribution.games.domain_name}"
  overwrite = true
}

resource "aws_lambda_function" "event_handler_function" {
  depends_on = [
    //null_resource.build_functions,
    aws_iam_role.event_handler_role,
    aws_s3_bucket.games]
  function_name = "${local.resource_prefix}_event_handler"
  description = "Backend function for the Event Handler API"
  filename = "functions/deploy/streaming-games-1.0.jar"
  source_code_hash = filemd5("functions/deploy/streaming-games-1.0.jar")
  handler = "com.gnatali.streaming.games.EventHandler"
  role = aws_iam_role.event_handler_role.arn
  runtime = "java11"
  memory_size = 512
  timeout = 60
  environment {
    variables = {
      ORIGIN_ALLOWED_SSM_PARAM = local.ssm_parameter_name
      KSQLDB_ENDPOINT = confluent_ksql_cluster.main.rest_endpoint
      KSQLDB_API_AUTH_INFO = local.ksql_basic_auth_user_info
      BOOTSTRAP_SERVER = confluent_kafka_cluster.games-demo.bootstrap_endpoint
      KAFKA_API_KEY = confluent_api_key.app-manager-kafka-api-key.id
      KAFKA_API_SECRET = confluent_api_key.app-manager-kafka-api-key.secret
      SR_ENDPOINT = confluent_schema_registry_cluster.essentials.rest_endpoint
      SR_API_KEY = confluent_api_key.sr_cluster_key.id
      SR_API_SECRET = confluent_api_key.sr_cluster_key.secret
    }
  }
}

resource "aws_lambda_permission" "event_handler_api_gateway_trigger" {
  statement_id = "AllowExecutionFromApiGateway"
  action = "lambda:InvokeFunction"
  principal = "apigateway.amazonaws.com"
  function_name = aws_lambda_function.event_handler_function.function_name
  source_arn = "${aws_api_gateway_rest_api.event_handler_api.execution_arn}/${aws_api_gateway_stage.event_handler_v1.stage_name}/*"
}

resource "aws_lambda_permission" "event_handler_cloudwatch_trigger" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  principal = "events.amazonaws.com"
  function_name = aws_lambda_function.event_handler_function.function_name
  source_arn = aws_cloudwatch_event_rule.event_handler_every_minute.arn
}

resource "aws_cloudwatch_event_rule" "event_handler_every_minute" {
  name = "${local.resource_prefix}-execute-event-handler-every-minute"
  description = "Execute the event handler function every minute"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "event_handler_every_minute" {
  rule = aws_cloudwatch_event_rule.event_handler_every_minute.name
  target_id = aws_lambda_function.event_handler_function.function_name
  arn = aws_lambda_function.event_handler_function.arn
  input = local.generic_wake_up
}
