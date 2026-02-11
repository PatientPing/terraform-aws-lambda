variable "aws_region" {
  default     = "us-east-1"
  description = "The region of AWS"
}

variable "vpc_config" {
  type = map(list(string))

  default = {
    subnet_ids         = []
    security_group_ids = []
  }
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "function_name" {
  type = string
}

variable "description" {
  type = string
}

variable "runtime" {
  type = string
}

variable "publish" {
  default = false
}

variable "handler" {
  type = string
}

variable "filename" {
  type    = string
  default = ""
}

variable "environment_variables" {
  type = map(string)
}

variable "source_mappings" {
  type    = list(any)
  default = []
}

variable "trigger_schedule" {
  type = map(any)

  default = {
    enabled = 0
  }
}

variable "trigger_input_parameters_json" {
  default = <<JSON
      {}
    JSON
}

variable "sns_topic_subscription" {
  type = map(any)

  default = {
    enabled = false
  }
}

variable "policies" {
  type    = list(any)
  default = []
}

variable "permissions" {
  type = map(any)

  default = {
    enabled = false
  }
}

variable "bucket_trigger" {
  type = map(any)

  default = {
    enabled = false
  }
}

variable "memory_size" {
  type = string
}

variable "timeout" {
  type = string
}

variable "create_empty_function" {
  default = true
}

variable "reserved_concurrent_executions" {
  default = "-1"
}

variable "github_url" {
  type    = string
  default = ""
}

variable "codebuild_image" {
  type    = string
  default = "aws/codebuild/standard:7.0"
}

variable "privileged_mode" {
  type    = string
  default = false
}

variable "layers" {
  type    = list(string)
  default = []
}

variable "codebuild_credential_arn" {
  type    = string
  default = ""
}

variable "codebuild_can_run_integration_test" {
  type    = bool
  default = false
}

variable "build_timeout" {
  type    = string
  default = "60"
}

variable "git_branch" {
  type    = string
  default = "master"
}

variable "ephemeral_storage" {
  type    = number
  default = 512
}

variable "create_codebuild_to_run_unit_test" {
  type        = bool
  default     = false
  description = "If true, will create codebuild and all the resources for running unit tests"
}

variable "git_base_ref_for_unit_test" {
  type        = string
  default     = "^refs/heads/main$"
  description = "The base ref for the codebuild webhook to run unit tests"
}

variable "log_group_name" {
  type        = string
  default     = null
  description = "If set, will create a log group with that name for the lambda, otherwise the default name (/aws/lambda/<function name>) will be used"
}

variable "log_retention_in_days" {
  type    = number
  default = 0 # Never expire
}

variable "log_skip_destroy" {
  type        = bool
  default     = true
  description = "If true, the log group will not be destroyed when the lambda is destroyed"
}

variable "ship_logs_to_sumo" {
  type        = bool
  default     = false
  description = "If true, will create a subscription filter to send logs to Sumo Logic"
}

variable "log_tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the log group. Defaults to the same tags as the lambda function if nothing is passed in."
}

variable "use_docker" {
    type        = bool
    default     = false
}

variable "github_token_path" {
  type        = string
  default     = "/cloudeng/infra/github/token"
  description = "Path to the GitHub token in parameter store"
}

variable "direct_build" {
  type        = bool
  default     = false
  description = "Enable Terraform-native Docker build during apply. When false, existing CodeBuild pattern is used."
}

variable "git_commit_sha" {
  type        = string
  default     = ""
  description = "The git commit SHA to build. Required when direct_build is true and github_url is set."
}

variable "docker_build_dir" {
  type        = string
  default     = "."
  description = "Subdirectory within the cloned repo to use as Docker build context."
}

variable "docker_build_args" {
  type        = map(string)
  default     = {}
  description = "Additional build arguments to pass to docker build."
}
