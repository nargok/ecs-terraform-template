resource "aws_rds_cluster_parameter_group" "this" {
  name = local.name_env
  family = "aurora-mysql:8.0"
  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_connection"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_results"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
  parameter {
    name         = "lower_case_table_names"
    value        = "1"
    apply_method = "pending-reboot"
  }
  parameter {
    name  = "time_zone"
    value = "Asia/Tokyo"
  }
  parameter {
    name  = "slow_query_log"
    value = "1"
  }
  parameter {
    name  = "long_query_time"
    value = "1"
  }
}

resource "aws_db_parameter_group" "this" {
  name = local.name_env
  family = "aurora-mysql8.0"
}

resource "aws_db_subnet_group" "this" {
  name = local.name_env
  subnet_ids = [for s in aws_subnet.db : s.id]
}

resource "aws_iam_role" "db_monitoring" {
  name = "${local.name_env}-db-monitoring"
  assume_role_policy = templatefile("assume-role-policy.tmpl", { service = "\"monitoring.rds.amazonaws.com\""})
}

resource "aws_iam_role_policy_attachment" "db_monitoring" {
  role = aws_iam_role.db_monitoring.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_rds_cluster" "this" {
  cluster_identifier_prefix = "${local.name_env}-"
  engine = "aurora-mysql"
  engine_version = "8.0.mysql_aurora.3.09.0"
  availability_zones = [for s in aws_subnet.db : s.availability_zone]
  database_name = var.db_name
  master_username = var.db_username
  master_password = var.db_password
  backup_retention_period = 5
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this.id
  db_subnet_group_name = aws_db_subnet_group.this.id
  storage_encrypted = true
  vpc_security_group_ids = [aws_security_group.db.id]
  skip_final_snapshot = true
  snapshot_identifier = jsoncode(var.db_snapshot)
  enabled_cloudwatch_logs_exports = [
    "error",
    "slowquery"
  ]

  lifecycle {
    ignore_changes = [
      engine_version,
    ]
  }
}

resource "aws_rds_cluster_instance" "this" {
  count = var.db_instance_count
  identifier_prefix = "${local.name_env}-"
  engine = aws_rds_cluster.this.engine
  engine_version = aws_rds_cluster.this.engine_version
  instance_class = var.db_instance_class
  cluster_identifier = aws_rds_cluster.this.id
  monitoring_interval = 60
  monitoring_role_arn = aws_iam_roel.db_monitoring.arn
  db_subnet_group_name = aws_rds_cluster.this.db_subnet_group_name
  db_parameter_group_name = aws_db_parameter_group.this.id
  performance_insights_enabled = var.db_performance_insights_enabled
  copy_tags_to_snapshot = true
  apply_immediately = true
}

