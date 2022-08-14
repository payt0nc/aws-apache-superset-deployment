resource "aws_elasticache_cluster" "superset_cache" {
  cluster_id           = "superset-cache"
  engine               = "redis"
  node_type            = "cache.t4g.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis6.x"
  engine_version       = "6.2"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.superset_cache.name
  security_group_ids   = [aws_security_group.superset_private_connection.id]
  apply_immediately    = true

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.superset.name
    destination_type = "cloudwatch-logs"
    log_format       = "text"
    log_type         = "slow-log"
  }

  tags = {
    Service = "Superset"
    Managed = "Terraform"
  }
}

resource "aws_elasticache_subnet_group" "superset_cache" {
  name       = "superset-cache-subnet"
  subnet_ids = [for x in data.aws_subnet.private : x.id]
}
