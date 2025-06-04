variable "region" {
  default = "ap-northeast-1"
}

variable "name" {
  default = "myapp" # TODO change your application name
}

variable "env" {} # ex.) dev, stage, prod

variable "ecs_container_insights" {}

variable "ecs_log_retention_in_days" {}

variable "ecs_cpu" {}

variable "ecs_memory" {}

variable "spring_profile" {}

variable "db_name" {}

variable "db_username" {}

variable "db_password" {}

variable "db_snapshot" {}

variable "db_instance_count" {}

variable "db_instance_class" {}

variable "db_performance_insights_enabled" {}

locals {
  name_env = "${var.name}-${var.env}"
}

