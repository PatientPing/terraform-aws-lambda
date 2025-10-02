locals {
  log_group_name = var.log_group_name == null ? "/aws/lambda/${var.function_name}" : var.log_group_name
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  count             = var.manage_log_group ? 1 : 0
  name              = local.log_group_name
  retention_in_days = var.log_retention_in_days
  tags              = var.log_tags == {} ? var.tags : var.log_tags
  skip_destroy      = var.log_skip_destroy
}

resource "aws_cloudwatch_log_subscription_filter" "example_subscription_filter" {
  count           = var.ship_logs_to_sumo ? 1 : 0
  name            = coalesce(var.subscription_filter_name, "${var.function_name}_subscription_filter")
  log_group_name  = var.manage_log_group ? aws_cloudwatch_log_group.lambda_log_group[0].name : local.log_group_name
  destination_arn = "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:SumoCWLogsLambda"
  filter_pattern  = ""
}

resource "aws_lambda_function" "lambda" {
  function_name                  = var.function_name
  description                    = var.description
  role                           = aws_iam_role.lambda.arn
  handler                        = var.handler
  runtime                        = var.runtime
  filename                       = var.create_empty_function ? "${path.module}/placeholder.zip" : var.filename
  timeout                        = var.timeout
  memory_size                    = var.memory_size
  reserved_concurrent_executions = var.reserved_concurrent_executions
  publish                        = var.publish
  layers                         = var.layers

  ephemeral_storage {
    size = var.ephemeral_storage
  }
  vpc_config {
    subnet_ids         = var.vpc_config["subnet_ids"]
    security_group_ids = var.vpc_config["security_group_ids"]
  }

  environment {
    variables = var.environment_variables
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      filename,
    ]
  }
}
