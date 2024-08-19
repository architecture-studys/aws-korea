resource "random_string" "ecs_random_employee" {
  length  = 5
  upper   = false
  lower   = false
  numeric = true
  special = false
}

resource "aws_launch_configuration" "employee-ecs" {
  image_id             = data.aws_ssm_parameter.ecs_latest_ami_2023.value
  iam_instance_profile = aws_iam_instance_profile.ecs.name
  security_groups      = [aws_security_group.ecs.id]
  user_data            = "#!/bin/bash\necho ECS_CLUSTER=${aws_ecs_cluster.cluster.name} >> /etc/ecs/ecs.config"
  instance_type        = "t3.micro"
}

resource "aws_autoscaling_group" "employee" {
  name                      = "employee-svc"
  vpc_zone_identifier       = [
    aws_subnet.app_a.id,
    aws_subnet.app_b.id,
  ]
  desired_capacity          = 2
  min_size                  = 2
  max_size                  = 10
  health_check_grace_period = 300
  health_check_type         = "EC2"

  launch_configuration = aws_launch_configuration.employee-ecs.name
  protect_from_scale_in = false

  tag {
    key                 = "AmazonECSManaged"
    value               = "true"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "apdev-ecs-employee"
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}

resource "aws_ecs_capacity_provider" "employee" {
  name = "ec2_capacity-${random_string.ecs_random_employee.result}"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.employee.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 60
    }
  }
}
