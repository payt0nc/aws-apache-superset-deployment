resource "aws_secretsmanager_secret" "superset_db_username" {
  name = "superset/metastore/username"
}

resource "aws_secretsmanager_secret" "superset_db_password" {
  name = "superset/metastore/password"
}

resource "aws_secretsmanager_secret" "superset_secret_key" {
  name = "superset/secret_key"
}
