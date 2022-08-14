resource "aws_security_group" "superset_private_connection" {
  name        = "Allow Superset Private Connection"
  description = "superset_private_connection"
  vpc_id      = data.aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "Allow_Superset_Private_Connection"
    Service = "SuperSet"
    Managed = "Terraform"
  }

}

resource "aws_security_group" "superset_public_access" {
  name        = "Allow Public TLS Access"
  description = "Allow Public TLS Access"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    description = "Allow TLS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["114.32.124.7/32"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["114.32.124.7/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "Allow_Public_TLS"
    Service = "SuperSet"
    Managed = "Terraform"
  }
}


resource "aws_security_group_rule" "to_postgres" {
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.vpc.cidr_block]
  security_group_id = aws_security_group.superset_private_connection.id
}

resource "aws_security_group_rule" "to_redis" {
  type              = "ingress"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.vpc.cidr_block]
  security_group_id = aws_security_group.superset_private_connection.id
}

resource "aws_security_group_rule" "intra_all" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["10.46.0.0/16"]
  security_group_id = aws_security_group.superset_private_connection.id
}
