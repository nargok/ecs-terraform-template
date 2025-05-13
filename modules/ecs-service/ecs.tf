resource "aws_cloudwatch_log_group" "this" {
  name = "/${var.cloudwatch_in_days}"
  retention_in_days = var.log_retention_in_days
}

data "aws_region" "this" {}
