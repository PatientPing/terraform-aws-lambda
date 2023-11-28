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
  default = "aws/codebuild/standard:4.0"
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