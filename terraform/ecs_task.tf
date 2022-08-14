resource "aws_ecs_task_definition" "superset" {
  family                   = "superset"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 2048
  memory                   = 4096
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.superset_instance.arn
  task_role_arn            = aws_iam_role.superset_instance.arn
  container_definitions    = <<TASK_DEFINITION
  [
    {
        "name": "superset",
        "image": "${aws_ecr_repository.superset.repository_url}:latest",
        "memoryReservation": null,
        "resourceRequirements": null,
        "readonlyRootFilesystem": false,
        "essential": true,
        "portMappings": [
            {
                "containerPort": 8088,
                "protocol": "tcp"
            }
        ],
        "environment": [
            {
                "name": "FLASK_ENV",
                "value": "production"
            },
            {
                "name": "SUPERSET_ENV",
                "value": "production"
            },
            {
                "name": "WEBDRIVER_BASEURL",
                "value": "https://superset.demo.nanami.me/"
            },
            {
                "name": "REDIS_HOST",
                "value": "${aws_elasticache_cluster.superset_cache.cache_nodes[0].address}"
            },
            {
                "name": "DATABASE_DIALECT",
                "value": "postgresql"
            },
            {
                "name": "DATABASE_HOST",
                "value": "${data.aws_db_instance.database.address}"
            },
            {
                "name": "DATABASE_PORT",
                "value": "${data.aws_db_instance.database.port}"
            },
            {
                "name": "DATABASE_DB",
                "value": "superset"
            }
        ],
        "environmentFiles": [],
        "secrets": [
            {
                "name": "SUPERSET_SECRET_KEY",
                "valueFrom": "${aws_secretsmanager_secret.superset_secret_key.arn}"
            },
            {
                "name": "DATABASE_USER",
                "valueFrom": "${aws_secretsmanager_secret.superset_db_username.arn}"
            },
            {
                "name": "DATABASE_PASSWORD",
                "valueFrom": "${aws_secretsmanager_secret.superset_db_password.arn}"
            }
        ],
        "mountPoints": null,
        "volumes" : null,
        "volumesFrom": null,
        "hostname": null,
        "user": null,
        "workingDirectory": null,
        "extraHosts": null,
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "${aws_cloudwatch_log_group.superset.name}",
                "awslogs-region": "ap-northeast-1",
                "awslogs-stream-prefix": "ecs"
            }
        },
        "ulimits": null,
        "dockerLabels": null,
        "dependsOn": null,
        "healthCheck": {
            "command": [
                "CMD-SHELL",
                "curl -f http://localhost:8088/health || exit 1"
            ],
            "interval": 10,
            "timeout": 2,
            "startPeriod": 60,
            "retries": 2
        },
        "command": [
            "/app/docker/docker-bootstrap.sh", "app-gunicorn"
        ]
    },
    {
        "name": "superset-worker",
        "image": "${aws_ecr_repository.superset.repository_url}:latest",
        "memoryReservation": null,
        "resourceRequirements": null,
        "readonlyRootFilesystem": false,
        "essential": true,
        "portMappings": [],
        "environment": [
            {
                "name": "FLASK_ENV",
                "value": "production"
            },
            {
                "name": "SUPERSET_ENV",
                "value": "production"
            },
            {
                "name": "WEBDRIVER_BASEURL",
                "value": "https://superset.demo.nanami.me/"
            },
            {
                "name": "REDIS_HOST",
                "value": "${aws_elasticache_cluster.superset_cache.cache_nodes[0].address}"
            },
            {
                "name": "DATABASE_DIALECT",
                "value": "postgresql"
            },
            {
                "name": "DATABASE_HOST",
                "value": "${data.aws_db_instance.database.address}"
            },
            {
                "name": "DATABASE_PORT",
                "value": "${data.aws_db_instance.database.port}"
            },
            {
                "name": "DATABASE_DB",
                "value": "superset"
            }
        ],
        "environmentFiles": [],
        "secrets": [
            {
                "name": "SUPERSET_SECRET_KEY",
                "valueFrom": "${aws_secretsmanager_secret.superset_secret_key.arn}"
            },
            {
                "name": "DATABASE_USER",
                "valueFrom": "${aws_secretsmanager_secret.superset_db_username.arn}"
            },
            {
                "name": "DATABASE_PASSWORD",
                "valueFrom": "${aws_secretsmanager_secret.superset_db_password.arn}"
            }
        ],
        "mountPoints": null,
        "volumesFrom": null,
        "hostname": null,
        "user": null,
        "workingDirectory": null,
        "extraHosts": null,
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "${aws_cloudwatch_log_group.superset.name}",
                "awslogs-region": "ap-northeast-1",
                "awslogs-stream-prefix": "ecs"
            }
        },
        "ulimits": null,
        "dockerLabels": null,
        "dependsOn": null,
        "healthCheck": {
            "command": [
                "CMD-SHELL",
                "echo '1'"
            ],
            "interval": 10,
            "timeout": 2,
            "startPeriod": 60,
            "retries": 2
        },
        "command": [
            "/app/docker/docker-bootstrap.sh", "worker"
        ]
    },
    {
        "name": "superset-beat",
        "image": "${aws_ecr_repository.superset.repository_url}:latest",
        "memoryReservation": null,
        "resourceRequirements": null,
        "readonlyRootFilesystem": false,
        "essential": true,
        "portMappings": [],
        "environment": [
            {
                "name": "FLASK_ENV",
                "value": "production"
            },
            {
                "name": "SUPERSET_ENV",
                "value": "production"
            },
            {
                "name": "WEBDRIVER_BASEURL",
                "value": "https://superset.demo.nanami.me/"
            },
            {
                "name": "REDIS_HOST",
                "value": "${aws_elasticache_cluster.superset_cache.cache_nodes[0].address}"
            },
            {
                "name": "DATABASE_DIALECT",
                "value": "postgresql"
            },
            {
                "name": "DATABASE_HOST",
                "value": "${data.aws_db_instance.database.address}"
            },
            {
                "name": "DATABASE_PORT",
                "value": "${data.aws_db_instance.database.port}"
            },
            {
                "name": "DATABASE_DB",
                "value": "superset"
            }
        ],
        "environmentFiles": [],
        "secrets": [
            {
                "name": "SUPERSET_SECRET_KEY",
                "valueFrom": "${aws_secretsmanager_secret.superset_secret_key.arn}"
            },
            {
                "name": "DATABASE_USER",
                "valueFrom": "${aws_secretsmanager_secret.superset_db_username.arn}"
            },
            {
                "name": "DATABASE_PASSWORD",
                "valueFrom": "${aws_secretsmanager_secret.superset_db_password.arn}"
            }
        ],
        "mountPoints": null,
        "volumesFrom": null,
        "hostname": null,
        "user": null,
        "workingDirectory": null,
        "extraHosts": null,
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "${aws_cloudwatch_log_group.superset.name}",
                "awslogs-region": "ap-northeast-1",
                "awslogs-stream-prefix": "ecs"
            }
        },
        "ulimits": null,
        "dockerLabels": null,
        "dependsOn": null,
        "healthCheck": {
            "command": [
                "CMD-SHELL",
                "echo '1'"
            ],
            "interval": 10,
            "timeout": 2,
            "startPeriod": 60,
            "retries": 2
        },
        "command": [
            "/app/docker/docker-bootstrap.sh", "beat"
        ]
    },
    {
        "name": "superset-init",
        "image": "${aws_ecr_repository.superset.repository_url}:latest",
        "memoryReservation": null,
        "resourceRequirements": null,
        "readonlyRootFilesystem": false,
        "essential": false,
        "portMappings": [],
        "environment": [
            {
                "name": "FLASK_ENV",
                "value": "production"
            },
            {
                "name": "SUPERSET_ENV",
                "value": "production"
            },
            {
                "name": "WEBDRIVER_BASEURL",
                "value": "https://superset.demo.nanami.me/"
            },
            {
                "name": "REDIS_HOST",
                "value": "${aws_elasticache_cluster.superset_cache.cache_nodes[0].address}"
            },
            {
                "name": "DATABASE_DIALECT",
                "value": "postgresql"
            },
            {
                "name": "DATABASE_HOST",
                "value": "${data.aws_db_instance.database.address}"
            },
            {
                "name": "DATABASE_PORT",
                "value": "${data.aws_db_instance.database.port}"
            },
            {
                "name": "DATABASE_DB",
                "value": "superset"
            }
        ],
        "environmentFiles": [],
        "secrets": [
            {
                "name": "SUPERSET_SECRET_KEY",
                "valueFrom": "${aws_secretsmanager_secret.superset_secret_key.arn}"
            },
            {
                "name": "DATABASE_USER",
                "valueFrom": "${aws_secretsmanager_secret.superset_db_username.arn}"
            },
            {
                "name": "DATABASE_PASSWORD",
                "valueFrom": "${aws_secretsmanager_secret.superset_db_password.arn}"
            }
        ],
        "mountPoints": null,
        "volumesFrom": null,
        "hostname": null,
        "user": null,
        "workingDirectory": null,
        "extraHosts": null,
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "${aws_cloudwatch_log_group.superset.name}",
                "awslogs-region": "ap-northeast-1",
                "awslogs-stream-prefix": "ecs"
            }
        },
        "ulimits": null,
        "dockerLabels": null,
        "dependsOn": null,
        "healthCheck": {
            "command": [
                "CMD-SHELL",
                "echo '1'"
            ],
            "interval": 10,
            "timeout": 2,
            "startPeriod": 60,
            "retries": 2
        },
        "command": [
            "/app/docker/docker-bootstrap.sh", "beat"
        ]
    }
  ]
  TASK_DEFINITION
}
