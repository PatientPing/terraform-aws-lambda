locals {
  log_group_name   = var.log_group_name == null ? "/aws/lambda/${var.function_name}" : var.log_group_name
  sumo_url_nonprod = "https://endpoint4.collection.sumologic.com/receiver/v1/http/ZaVnC4dhaV0ao2ExQYwmLW4hoL8VbQDQWdmhj8Ojl7HlhSVOTgSlruBYklxlsqldlUyKLu3XXcSaOWTLcD_IxeI3VLHwhqttwDem8whV0JsB53slszdDUQ=="
  sumo_url_prod    = "https://endpoint4.collection.sumologic.com/receiver/v1/http/ZaVnC4dhaV0aoMJW0JPZTDCAbMiIdthg3-v7oZZxA_1ehOVR7kSNMipXTIN1ArpkKe2vl70z9RXd5_wYFaGiLJZ2IqLKQIz25qU3sWQxuq9C7tHCJ0xm9w=="
  sumo_endpoint_url_mapping = {
    "499407627146" : local.sumo_url_prod,
    "139270343000" : local.sumo_url_prod,
    "085651866557" : local.sumo_url_nonprod,
    "225726765411" : local.sumo_url_nonprod,
    "334700497158" : local.sumo_url_nonprod,
    "934421957606" : local.sumo_url_nonprod,
    "424344727374" : local.sumo_url_nonprod,
    "755176673017" : local.sumo_url_nonprod,
    "389016375993" : local.sumo_url_prod,
    "691648844592" : local.sumo_url_prod,
    "651305130338" : local.sumo_url_prod,
    "477845385016" : local.sumo_url_prod,
    "066045530129" : local.sumo_url_prod,
    "523930181136" : local.sumo_url_prod,
    "551052347425" : local.sumo_url_nonprod,
    "011516987840" : local.sumo_url_prod,
    "614143157168" : local.sumo_url_prod,
    "050919298421" : local.sumo_url_prod,
    "079655036558" : local.sumo_url_nonprod,
  }
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = local.log_group_name
  retention_in_days = var.log_retention_in_days
  tags              = var.log_tags == {} ? var.tags : var.log_tags
  skip_destroy      = var.log_skip_destroy
}

resource "aws_cloudwatch_log_subscription_filter" "example_subscription_filter" {
  count           = var.ship_logs_to_sumo ? 1 : 0
  name            = "${var.function_name}_subscription_filter"
  log_group_name  = aws_cloudwatch_log_group.lambda_log_group.name
  destination_arn = "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:SumoCWLogsLambda"
  filter_pattern  = ""
}

resource "aws_lambda_function" "lambda" {
  function_name                  = var.function_name
  description                    = var.description
  role                           = aws_iam_role.lambda.arn
  handler                        = var.use_docker ? null : var.handler
  runtime                        = var.use_docker ? null : var.runtime
  filename                       = var.use_docker ? null : var.create_empty_function ? "${path.module}/placeholder.zip" : var.filename
  image_uri                      = var.use_docker ? (var.direct_build && var.github_url != "" ? "${aws_ecr_repository.lambda_ecr_repo[0].repository_url}:${var.git_commit_sha}" : "${aws_ecr_repository.lambda_ecr_repo[0].repository_url}:latest") : null
  timeout                        = var.timeout
  memory_size                    = var.memory_size
  reserved_concurrent_executions = var.reserved_concurrent_executions
  publish                        = var.publish
  layers                         = var.layers
  package_type                   = var.use_docker ? "Image" : null

  ephemeral_storage {
    size = var.ephemeral_storage
  }
  vpc_config {
    subnet_ids         = var.vpc_config["subnet_ids"]
    security_group_ids = var.vpc_config["security_group_ids"]
  }

  environment {
    variables = merge(var.environment_variables, {
      SUMO_HTTP_ENDPOINT = lookup(local.sumo_endpoint_url_mapping, data.aws_caller_identity.current.account_id, null)
    })
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      filename,
    ]
  }

  depends_on = [null_resource.push_docker_image, null_resource.docker_build]
}
