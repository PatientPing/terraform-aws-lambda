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

output "version" {
  value = aws_lambda_function.lambda.version
}

output "qualified_arn" {
  value = aws_lambda_function.lambda.qualified_arn
}

output "alias_name" {
  value = try(aws_lambda_alias.lambda[0].name, null)
}

output "alias_arn" {
  value = try(aws_lambda_alias.lambda[0].arn, null)
}

output "alias_invoke_arn" {
  value = try(aws_lambda_alias.lambda[0].invoke_arn, null)
}

output "codebuild_role" {
  value = aws_iam_role.codebuild
}
