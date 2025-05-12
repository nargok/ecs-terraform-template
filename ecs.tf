resource "aws_ecs_cluster" "this" {
  name = local.name_env
  setting = {
    name = "containerInsights"
    value = var.ecs_container_insights
  }
}

resource "aws_iam_role" "ecs_execution" {
  name = "${local.name_env}-ecs-execution"
  assume_role_policy = templatefile("assume-role-policy.tmpl", { service = "\"ecs-tasks.amazon.com\"" })
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  for_each = toset([
    # ECSタスクがECRからイメージをpullする。CloudWatchにログを送信するための権限
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
    # パラメータストアから設定値を読み取る権限
    "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
  ])
  role = aws_iam_role.ecs_execution.id
  policy_arn = each.value
}

resource "aws_iam_role" "ecs_task" {
  name = "${local.name_env}-ecs-task"
  assume_role_policy = templatefile("assume-role-policy.tmpl", { service = "\"ecs-tasks.amazon.com\"" })
}


resource "aws_iam_role_policy_attachment" "ecs_task" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonSESFullAccess"
  ])
  role = aws_iam_role.ecs_task.id
  policy_arn = each.value
}

