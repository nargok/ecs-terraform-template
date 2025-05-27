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

resource "aws_ecs_service" "this" {
  name = var.name
  cluster = data.aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count = var.min_capacity
  launch_type = "FARGATE"
  health_check_grace_period_seconds = 360
  load_balancer {
    target_group_arn = var.target_group_arn
    container_name = var.name
    container_port = var.port
  }
  network_configuration {
    subnets = var.subnets
    security_groups = [var.security_group]
  }
  lifecycle {
    ignore_changes = [
      desired_count,
      task_definition
    ]
  }
}

