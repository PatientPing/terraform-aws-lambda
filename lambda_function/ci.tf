terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "3.2.3"
    }
  }
}
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "codebuild" {
  count = var.github_url == "" ? 0 : 1

  name = "codebuild_${var.function_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild" {
  count = var.github_url == "" ? 0 : 1
  role = aws_iam_role.codebuild[0].name
  policy = data.aws_iam_policy_document.policy.json
}

data "aws_iam_policy_document" "policy" {
  statement {
    effect = "Allow"
    resources = ["*"]
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"]
  }
  statement {
    effect = "Allow"
    resources = [
      aws_lambda_function.lambda.arn]
    actions = [
      "lambda:UpdateFunctionCode",
      "lambda:ListVersionsByFunction",
      "lambda:UpdateAlias"
    ]
  }
  dynamic "statement" {
    for_each = var.codebuild_can_run_integration_test ? ["allow_invoke"] : []
    content {
      effect = "Allow"
      resources = [aws_lambda_function.lambda.arn]
      actions = ["lambda:InvokeFunction", "lambda:GetFunctionConfiguration"]
    }
  }
  dynamic "statement" {
    for_each = var.use_docker ? ["allow_ecr"] : []
    content {
      effect = "Allow"
      resources = ["*"]
      actions = [
        "ecr:BatchCheckLayerAvailability",
        "ecr:CompleteLayerUpload",
        "ecr:GetAuthorizationToken",
        "ecr:InitiateLayerUpload",
        "ecr:PutImage",
        "ecr:UploadLayerPart"
      ]
    }
  }
  dynamic "statement" {
    for_each = var.use_docker ? ["allow_docker_secrets"] : []
    content {
      effect = "Allow"
      actions = [
        "ssm:GetParameter*"
      ]
      resources = ["arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.github_token_path}"]
      ]
    }
  }

}

resource "aws_codebuild_project" "lambda" {
  count = var.github_url == "" ? 0 : 1

  name          = var.function_name
  build_timeout = var.build_timeout
  service_role  = aws_iam_role.codebuild[0].arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = var.codebuild_image
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    environment_variable {
      name = "run_integration_test"
      value = var.codebuild_can_run_integration_test
    }
    environment_variable {
      name  = "lambda_function_name"
      value = var.function_name
    }
  }

  source {
    type            = "GITHUB"
    location        = var.github_url
    git_clone_depth = 1
    buildspec       = var.use_docker ? templatefile("${path.module}/docker_buildspec.yml", {gh_token = var.github_token_path}) : "buildspec.yml"
  }
}

resource "aws_codebuild_webhook" "lambda" {
  count = var.github_url == "" ? 0 : 1

  project_name = aws_codebuild_project.lambda[0].name

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH"
    }

    filter {
      type    = "HEAD_REF"
      pattern = var.git_branch
    }
  }
}

resource aws_ecr_repository "lambda_ecr_repo" {
  count = var.use_docker ? 1 : 0
  name  = var.function_name

}


resource "null_resource" "push_docker_image" {
  count = var.use_docker ? 1 : 0
  provisioner "local-exec" {
    command = <<EOF
    aws ecr get-login-password --region ${data.aws_region.current.name} | docker login --username AWS --password-stdin ${aws_ecr_repository.lambda_ecr_repo[0].repository_url}
    docker pull public.ecr.aws/lambda/python:3.12
    docker tag public.ecr.aws/lambda/python:3.12 ${aws_ecr_repository.lambda_ecr_repo[0].repository_url}
    docker push ${aws_ecr_repository.lambda_ecr_repo[0].repository_url}
EOF
  }
}

