resource "aws_ecs_service" "employee" {
  name            = "employee-svc"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.employee.arn
  desired_count   = 2
  health_check_grace_period_seconds = 0
  deployment_maximum_percent = 200
  deployment_minimum_healthy_percent = 100

  network_configuration {
    subnets = [
      aws_subnet.app_a.id,
      aws_subnet.app_b.id
    ]

    security_groups = [
      aws_security_group.ecs.id
    ]

    assign_public_ip = false
  }

  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.ecs-employee.arn
    container_name   = "employee-cnt"
    container_port   = 8080
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [ap-northeast-2a, ap-northeast-2b]"
  }

  capacity_provider_strategy {
    base = 1
    capacity_provider = aws_ecs_capacity_provider.employee.name
    weight = 100
  }

  lifecycle {
    ignore_changes = [desired_count, task_definition, capacity_provider_strategy]
  }

  depends_on = [
    aws_instance.bastion,
    aws_db_instance.db,
    aws_db_proxy.db,
    aws_db_proxy_target.rds_proxy,
    aws_secretsmanager_secret.db,
    aws_secretsmanager_secret_version.db
  ]
}