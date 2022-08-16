variable "aws_account_id" {
  type        = number
  description = "Account ID"
}

variable "aws_region" {
  type        = string
  description = "AWS Region"
  default     = "ap-northeast-1"
}

variable "aws_vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "aws_metadata_db_instance_identifier" {
  type        = string
  description = "RDS identifier for superset metadata"
}
variable "aws_alb_logging_bucket_name" {
  type = string
}

variable "aws_acm_endpoint_arn" {
  type        = string
  description = "ARN of TLS certication for Superset domain"
}

variable "aws_secret_manager_superset_secret_key_name" {
  type = string
}

variable "aws_secret_manager_superset_metadata_db_username_name" {
  type = string
}

variable "aws_secret_manager_superset_metadata_db_password_name" {
  type = string
}

variable "aws_route53_domain_zone" {
  type = string
}

variable "aws_route53_superset_domain_name" {
  type = string
}

data "aws_vpc" "vpc" {
  id = var.aws_vpc_id
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [var.aws_vpc_id]
  }

  tags = {
    Name = "*private-subnet*"
  }
}

data "aws_subnet" "private" {
  for_each = toset(data.aws_subnets.private.ids)
  id       = each.value
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [var.aws_vpc_id]
  }

  tags = {
    Name = "*public-subnet*"
  }
}

data "aws_subnet" "public" {
  for_each = toset(data.aws_subnets.public.ids)
  id       = each.value
}

data "aws_db_instance" "database" {
  db_instance_identifier = var.aws_metadata_db_instance_identifier
}

data "aws_s3_bucket" "alb_logging_bucket" {
  bucket = var.aws_alb_logging_bucket_name
}

data "aws_route53_zone" "demo" {
  name = var.aws_route53_domain_zone
}
