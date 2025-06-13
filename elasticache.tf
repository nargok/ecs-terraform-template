resource "aws_elasticache_subnet_group" "this" {
  name       = local.name_env
  subnet_ids = [for s in aws_subnet.elasticache : s.id]
}

resource "aws_elasticache_replication_group" "this" {
  automatic_failover_enabled  = true
  preferred_cache_cluster_azs = [for s in aws_subnet.elasticache : s.availability_zone]
  replication_group_id        = local.name_env
  description                 = local.name_env
  multi_az_enabled            = true
  node_type                   = "cache.t3.small"
  num_chache_clusters         = 2
  port                        = 6379
  subnet_group_name           = aws_elasticache_subnet_group.this.name
  security_group_ids          = [aws_security_group.elasticache.id]
}

