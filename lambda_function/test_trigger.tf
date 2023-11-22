resource "aws_iam_role" "unit_test_codebuild_role" {
  count = var.create_unit_test_resources == true ? 1 : 0
  name  = "${var.function_name}_ci_test"

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

resource "aws_iam_role_policy" "unit_test_codebuild" {
  count = var.create_unit_test_resources == true ? 1 : 0
  name  = "${var.function_name}_ci_test"
  role  = aws_iam_role.unit_test_codebuild_role.name

  policy = jsonencode({
    Version : "2012-10-17",
    Statement = [
      {
        Effect   = "Allow"
        Resource = [
          "arn:aws:codebuild:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:report-group/${aws_codebuild_project.unit_test_codebuild.name}-*"
        ]
        Action = [
          "codebuild:CreateReportGroup",
          "codebuild:CreateReport",
          "codebuild:UpdateReport",
          "codebuild:BatchPutTestCases",
          "codebuild:BatchPutCodeCoverages"
        ]
      },
      {
        Effect   = "Allow",
        Resource = [
          "*"
        ],
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameter*"
        ],
        Resource = [
          "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/cloudeng/infra/github/token"
        ]
      }
    ]
  })
}


resource "aws_codebuild_project" "unit_test_codebuild" {
  count        = var.create_unit_test_resources == true ? 1 : 0
  name         = "${var.function_name}_ci_test"
  service_role = aws_iam_role.unit_test_codebuild_role.arn

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
    git_clone_depth = 2
    buildspec       = "buildspec-tests.yml"
  }
}

resource "aws_codebuild_webhook" "unit_test_codebuild" {
  count        = var.create_unit_test_resources == true ? 1 : 0
  project_name = aws_codebuild_project.unit_test_codebuild.name

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PULL_REQUEST_CREATED, PULL_REQUEST_UPDATED, PULL_REQUEST_REOPENED"
    }
  }
}
