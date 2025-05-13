variable "region" {
  default = "ap-northeast-1"
}

variable "name" {
  default = "myapp" # TODO change your application name
}

variable "env" {} # ex.) dev, stage, prod

variable "ecs_container_insights" {}

variable "ecs_log_retention_in_days" {}

locals {
  name_env = "${var.name}-${var.env}"
}

