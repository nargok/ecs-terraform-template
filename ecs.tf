resource "aws_ecs_cluster" "this" {
  name = local.name_env
  setting = {
    name = "containerInsights"
    value = var.ecs_container_insights
  }
}
