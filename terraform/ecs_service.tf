resource "aws_ecs_cluster" "superset" {
  name = "superset"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.superset.name
      }
    }
  }

  tags = {
    Service = "Superset"
    Managed = "Terraform"
  }
}

resource "aws_ecs_cluster_capacity_providers" "superset" {
  cluster_name       = aws_ecs_cluster.superset.name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
}


resource "aws_ecs_service" "superset" {
  name            = "superset"
  desired_count   = 1
  cluster         = aws_ecs_cluster.superset.id
  task_definition = aws_ecs_task_definition.superset.arn
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.superset.arn
    container_name   = "superset"
    container_port   = 8088
  }

  network_configuration {
    assign_public_ip = false
    subnets          = data.aws_subnets.private.ids
    security_groups = [
      aws_security_group.superset_private_connection.id
    ]
  }

  tags = {
    Service = "Superset"
    Managed = "Terraform"
  }
}


resource "aws_route53_record" "superset" {
  zone_id = data.aws_route53_zone.demo.zone_id
  name    = var.aws_route53_superset_domain_name
  type    = "A"

  alias {
    name                   = aws_alb.superset.dns_name
    zone_id                = aws_alb.superset.zone_id
    evaluate_target_health = true
  }
}

resource "aws_acm_certificate" "superset" {
  domain_name       = var.aws_route53_superset_domain_name
  validation_method = "DNS"

  tags = {
    Service = "Superset"
    Managed = "Terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "superset" {
  name        = "superset"
  port        = 8088
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.vpc.id
  target_type = "ip"

  health_check {
    path     = "/health"
    port     = 8088
    interval = 30
  }
}
