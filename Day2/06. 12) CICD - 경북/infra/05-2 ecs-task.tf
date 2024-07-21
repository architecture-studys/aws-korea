data "aws_iam_policy_document" "assume_role_execution" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "execution" {
  name               = "wsi-role-execution"
  assume_role_policy = data.aws_iam_policy_document.assume_role_execution.json
}

data "aws_iam_policy_document" "execution" {
  statement {
    effect = "Allow"

    actions = [
      "logs:*",
      "ecr:*"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "execution" {
  role   = aws_iam_role.execution.name
  policy = data.aws_iam_policy_document.execution.json
}

resource "aws_ecs_task_definition" "td" {
  family                   = "wsi-td"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = 512
  memory                   = 1024
  execution_role_arn = aws_iam_role.execution.arn

  container_definitions = <<DEFINITION
[
  {
    "image": "nginx:latest",
    "cpu": 512,
    "memory": 1024,
    "name": "wsi-container",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ],
    "healthCheck": {
      "command": [
        "CMD-SHELL",
        "curl -fLs http://localhost:80/health > /dev/null || exit 1"
      ],
      "interval": 5,
      "timeout": 2,
      "retries": 1,
      "startPeriod": 0
    },
    "essential": true
  }
]
DEFINITION
}