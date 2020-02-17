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
  default = false
}

variable "reserved_concurrent_executions" {
  default = "-1"
}

variable "github_token_ssm_param" {
  type = string
}

variable "github_url" {
  type = string
}

variable "layers" {
  type = list(string)
  default = []
}