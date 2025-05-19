locals {
  _env_vars = {
    tz = "Asia/Tokyo"
  }
  _secrets = {
    db_user = aws_ssm_parameter.db_username.arn
    db_password = aws_ssm_parameter.db_password.arn
  }
  env_vars = [for k, v in local._env_vars : { name = upper(k), value = v }]
  secrets = [for k, v in local._secrets : { name = upper(k), valueFrom = v }]
  services = {
    web = {}
    batch = {}
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
  port = each.value.port
  secrets = local.secrets
}

