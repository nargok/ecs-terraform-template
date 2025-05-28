locals {
  _env_vars = {
    db_host = aws_rds_cluster.this.endpoint
    elasticache_host = aws_elasticache_replication_group.this.primary_endpoint_address
    spring_profiles_active = var.spring_profile
    tz = "Asia/Tokyo"
    aws_region = var.region
  }
  _secrets = {
    db_user = aws_ssm_parameter.db_username.arn
    db_password = aws_ssm_parameter.db_password.arn
  }
  env_vars = [for k, v in local._env_vars : { name = upper(k), value = v }]
  secrets = [for k, v in local._secrets : { name = upper(k), valueFrom = v }]
  services = {
    web = {
      autoscaling = false
      min_capacity = 1
      max_capacity = 1
      port = 18081
      target_group_arn = aws_lb_target_group.web.arn
      security_group = aws_security_group.web.id
    }
    batch = {
      autoscaling = false
      min_capacity = 1
      max_capacity = 1
      port = 8081
      target_group_arn = aws_lb_target_group.batch.arn
      security_group = aws_security_group.batch.id
    }
  }
}

module "ecs_service" {
  for_each = local.services
  source = "./modules/ecs-service"
  name = "${local.name_env}-${each.key}"
  cluster_name = aws_ecs_cluster.this.name
  env_vars = local.env_vars
  image = "${aws.ecr_repository.this[each.key].reposiroty_url}:${aws_ssm_parameter.deployment_image_tag.value}"
  log_retention_in_days = var.ecs_log_retention_in_days
  execution_role_arn = aws_iam_role.ecs_execution.arn
  task_role_arn = aws_iam_role.ecs_task.arn
  cpu = var.ecs_cpu
  memory = var.ecs_memory
  min_capacity = each.value.min_capacity
  max_capacity = each.value.max_capacity
  port = each.value.port
  secrets = local.secrets
  target_group_arn = each.value.target_group_arn
  subnets = [for s in aws_subnet.private : s.id]
  security_group = each.value.security_group
  autoscaling = each.value.autoscaling
}

