resource "aws_ecs_task_definition" "token" {
  family                   = "token-td"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = 819
  memory                   = 819
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  
  container_definitions = <<DEFINITION
[
  {
    "image": "${aws_ecr_repository.ecr.repository_url}:token",
    "cpu": 819,
    "memory": 819,
    "name": "token-cnt",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 8080
      }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "/ecs/",
            "awslogs-create-group": "true",
            "awslogs-region": "ap-northeast-2",
            "awslogs-stream-prefix": "ecs"
        }
    },
    "healthCheck": {
      "command": [
        "CMD-SHELL",
        "curl -fLs http://localhost:8080/healthcheck > /dev/null"
      ],
      "interval": 30,
      "timeout": 5,
      "retries": 3,
      "startPeriod": 0
    }
  }
]
DEFINITION

  depends_on = [
    aws_instance.bastion,
    aws_db_instance.db,
    aws_db_proxy.db,
    aws_db_proxy_target.rds_proxy,
    aws_secretsmanager_secret.db,
    aws_secretsmanager_secret_version.db
  ]
}
