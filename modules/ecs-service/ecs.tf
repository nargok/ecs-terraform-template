resource "aws_cloudwatch_log_group" "this" {
  name = "/${var.cloudwatch_in_days}"
  retention_in_days = var.log_retention_in_days
}

data "aws_region" "this" {}

resource "aws_ecs_task_definition" "this" {
  family = var.name
  container_definition = jsonencode([
    {
      name = var.name
      image = var.image
      environtment = var.env_vars
      secrets = var.secrets
      portMappings = [
        {
          containerPort = var.port
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group = aws_cloudwatch_log_group.this.name
          awslogs-region = data.aws_region.this.name
          awslogs-stream-prefix = var.name
        }
      }
    }
  ])
  cpu = var.cpu
  memory = var.memory
  requires_compatibility = ["FARGATE"]
  network_mode = "awsvpc"
  execution_role_arn = var.execution_role_arn
  task_role_arn = var.task_role_arn
}

data "aws_ecs_cluster" "this" {
  cluster_name = var.cluster_name
}

