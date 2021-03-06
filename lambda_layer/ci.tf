data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "codebuild" {
  count = var.github_url == "" ? 0 : 1

  name = "codebuild_${var.layer_name}"

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

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Resource": "${aws_lambda_layer_version.layer.layer_arn}",
      "Action": "lambda:PublishLayerVersion"
    }
  ]
}
EOF
}

resource "aws_codebuild_project" "lambda" {
  count = var.github_url == "" ? 0 : 1

  name          = var.layer_name
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
    privileged_mode             = var.privileged_mode
  }

  source {
    type            = "GITHUB"
    location        = var.github_url
    git_clone_depth = 1

    auth {
      type     = "OAUTH"
      resource = var.codebuild_credential_arn == "" ? "arn:aws:codebuild:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:token/github" : var.codebuild_credential_arn
    }
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
