resource "aws_iam_role" "superset_instance" {
  name = "superset_instance"
  assume_role_policy = jsonencode({
    "Version" : "2008-10-17",
    "Statement" : [
      {
        "Sid" : "1",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ecs.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      },
      {
        "Sid" : "2",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ecs-tasks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "ReadSupersetCredentials"
    policy = jsonencode(
      {
        "Version" : "2012-10-17",
        "Statement" : [
          {
            "Effect" : "Allow",
            "Action" : [
              "secretsmanager:GetSecretValue"
            ],
            "Resource" : [
              "${aws_secretsmanager_secret.superset_db_username.arn}",
              "${aws_secretsmanager_secret.superset_db_password.arn}",
              "${aws_secretsmanager_secret.superset_secret_key.arn}"
            ]
          }
        ]
      },
    )
  }

  tags = {
    Service = "Superset"
    Managed = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "add_ecs_task_execution_role_policy" {
  role       = aws_iam_role.superset_instance.name
  policy_arn = data.aws_iam_policy.ecs_task_execution_role_policy.arn
}

resource "aws_iam_role_policy_attachment" "add_cloud_watch_read_only_access" {
  role       = aws_iam_role.superset_instance.name
  policy_arn = data.aws_iam_policy.cloud_watch_read_only_access.arn
}

resource "aws_iam_role_policy_attachment" "add_cloud_watch_logs_read_only_access" {
  role       = aws_iam_role.superset_instance.name
  policy_arn = data.aws_iam_policy.cloud_watch_logs_read_only_access.arn
}

resource "aws_iam_role_policy_attachment" "add_secrets_manager_read_write" {
  role       = aws_iam_role.superset_instance.name
  policy_arn = data.aws_iam_policy.secrets_manager_read_write.arn
}

resource "aws_iam_role_policy_attachment" "add_get_image_from_ecr" {
  role       = aws_iam_role.superset_instance.name
  policy_arn = aws_iam_policy.get_image_from_ecr.arn
}

resource "aws_iam_role_policy_attachment" "add_push_log_to_cloud_watch" {
  role       = aws_iam_role.superset_instance.name
  policy_arn = aws_iam_policy.push_log_to_cloud_watch.arn
}

resource "aws_iam_role_policy_attachment" "add_allow_access_sqs" {
  role       = aws_iam_role.superset_instance.name
  policy_arn = aws_iam_policy.allow_access_sqs.arn
}

data "aws_iam_policy" "ecs_task_execution_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy" "cloud_watch_read_only_access" {
  arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}

data "aws_iam_policy" "cloud_watch_logs_read_only_access" {
  arn = "arn:aws:iam::aws:policy/CloudWatchLogsReadOnlyAccess"
}
data "aws_iam_policy" "secrets_manager_read_write" {
  arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}


resource "aws_iam_policy" "get_image_from_ecr" {
  name        = "GetContainerImageFromECR"
  path        = "/"
  description = "Get Container Image from ECR"
  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow",
          Action = [
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage"
          ],
          Resource = [
            "${aws_ecr_repository.superset.arn}"
          ]
        }
      ]
    }
  )

  tags = {
    Managed = "Terraform"
  }
}

resource "aws_iam_policy" "push_log_to_cloud_watch" {
  name        = "PushLogToCloudWatch"
  path        = "/"
  description = "Push Log to CloudWatch"
  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow",
          Action = [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          Resource = ["*"]
        }
      ]
    }
  )

  tags = {
    Managed = "Terraform"
  }
}

resource "aws_iam_policy" "allow_access_sqs" {
  name        = "AllowAccessSuperSetSQS"
  path        = "/"
  description = "Allow Access Superset SQS"
  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Effect   = "Allow",
          Action   = "sqs:*",
          Resource = "${aws_sqs_queue.superset_job_queue.arn}"
        }
      ]
    }
  )

  tags = {
    Managed = "Terraform"
  }
}
