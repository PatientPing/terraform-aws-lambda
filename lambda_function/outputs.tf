output "arn" {
  value = aws_lambda_function.lambda.arn
}

output "role" {
  value = aws_iam_role.lambda
}

output "function_name" {
  value = aws_lambda_function.lambda.function_name
}

output "invoke_arn" {
  value = aws_lambda_function.lambda.invoke_arn
}

output "codebuild_role" {
  value       = var.direct_build ? null : (length(aws_iam_role.codebuild) > 0 ? aws_iam_role.codebuild[0] : null)
  description = "Deprecated for direct builds. CodeBuild role for legacy builds."
}

output "ecr_repository_url" {
  value       = var.use_docker ? aws_ecr_repository.lambda_ecr_repo[0].repository_url : null
  description = "ECR repository URL. Only set when use_docker is true."
}

output "image_tag" {
  value       = var.direct_build && var.github_url != "" ? var.git_commit_sha : null
  description = "The commit SHA used as the image tag. Only set for direct builds."
}
