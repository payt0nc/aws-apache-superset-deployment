resource "aws_alb" "superset" {
  name               = "alb-superset"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.superset_public_access.id]
  subnets            = [for subnet in data.aws_subnet.public : subnet.id]

  enable_deletion_protection = true

  access_logs {
    bucket  = data.aws_s3_bucket.alb_logging_bucket.bucket
    prefix  = "alb-superset"
    enabled = true
  }

  tags = {
    Service = "Superset"
    Managed = "Terraform"
  }
}

resource "aws_alb_listener" "superset" {
  load_balancer_arn = aws_alb.superset.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.superset.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.superset.arn
  }

  tags = {
    Service = "Superset"
    Managed = "Terraform"
  }
}
