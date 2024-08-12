resource "aws_appautoscaling_target" "token-tg" {
  max_capacity = 12
  min_capacity = 2
  resource_id = "service/${aws_ecs_cluster.cluster.name}/${aws_ecs_service.token.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = "ecs"
}

resource "aws_appautoscaling_policy" "token-memory" {
  name               = "memory"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.token-tg.resource_id
  scalable_dimension = aws_appautoscaling_target.token-tg.scalable_dimension
  service_namespace  = aws_appautoscaling_target.token-tg.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value       = 80
  }
}

resource "aws_appautoscaling_policy" "token-cpu" {
  name = "cpu"
  policy_type = "TargetTrackingScaling"
  resource_id = aws_appautoscaling_target.token-tg.resource_id
  scalable_dimension = aws_appautoscaling_target.token-tg.scalable_dimension
  service_namespace = aws_appautoscaling_target.token-tg.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 70
  }
}

resource "aws_ecs_cluster_capacity_providers" "token-capacity" {
  cluster_name = aws_ecs_cluster.cluster.name

  capacity_providers = [
    aws_ecs_capacity_provider.token.name
  ]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.token.name
  }
}