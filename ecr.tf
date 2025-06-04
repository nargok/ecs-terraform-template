resource "aws_ecr_repository" "this" {
  for_each     = loacl.services
  name         = "{var.name}-${each.key}"
  force_delete = true
}
