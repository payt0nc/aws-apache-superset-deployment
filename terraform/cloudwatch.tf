resource "aws_cloudwatch_log_group" "superset" {
  name = "superset"

  tags = {
    Service = "Superset"
    Managed = "Terraform"
  }
}
