data "aws_iam_policy_document" "ecs" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs" {
  name               = "wsi-role-ecs"
  assume_role_policy = data.aws_iam_policy_document.ecs.json
}


resource "aws_iam_role_policy_attachment" "ecs" {
  role       = aws_iam_role.ecs.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs" {
  name = "wsi-ecs-profile"
  role = aws_iam_role.ecs.name
}

data "aws_ssm_parameter" "latest_ami_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-minimal-kernel-default-x86_64"
}

resource "aws_launch_configuration" "ecs" {
  image_id             = data.aws_ssm_parameter.latest_ami_2023.value
  iam_instance_profile = aws_iam_instance_profile.ecs.name
  security_groups      = [aws_security_group.ecs.id]
  user_data            = "#!/bin/bash\necho ECS_CLUSTER=${aws_ecs_cluster.cluster.name} >> /etc/ecs/ecs.config"
  instance_type        = "t3.medium"
}

resource "aws_autoscaling_group" "ecs" {
  name                      = "wsi-ecs-s"
  vpc_zone_identifier       = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id,
  ]
  launch_configuration      = aws_launch_configuration.ecs.name

  desired_capacity          = 1
  min_size                  = 1
  max_size                  = 10
  health_check_grace_period = 300
  health_check_type         = "EC2"

  protect_from_scale_in = true

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}

resource "aws_ecs_capacity_provider" "capacity" {
  name = "ec2_capacity"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 60
    }
  } 
}