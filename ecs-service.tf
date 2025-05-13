locals {
  services = {
    web = {}
    batch = {}
  }
}

module "ecs_service" {
  for_each = local.services
  source = "./modules/ecs-service"
  log_retention_in_days = var.ecs_log_retention_in_days
}

