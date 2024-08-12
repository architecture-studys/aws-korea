resource "aws_autoscaling_group" "token" {
  name                = "apdev-token"
  desired_capacity    = 2
  min_size            = 2
  max_size            = 20
  vpc_zone_identifier = [aws_subnet.app_a.id, aws_subnet.app_b.id]
  target_group_arns   = [aws_lb_target_group.token.arn]

  launch_template {
    id      = aws_launch_template.token.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "token" {
  name                   = "web-asg-policy"
  autoscaling_group_name = aws_autoscaling_group.token.name

  policy_type = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 70.0
  }
}

resource "aws_launch_template" "token" {
  name          = "apdev-token-tp"
  image_id      = data.aws_ssm_parameter.latest_ami.value
  instance_type = "t3.micro"
  key_name      = aws_key_pair.keypair.key_name
  iam_instance_profile {
    arn = aws_iam_instance_profile.app.arn
  }

  vpc_security_group_ids = [aws_security_group.app.id]
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "apdev-token"
    }
  }

  user_data = base64encode("${file("./src/token/userdata.sh")}"
  )

  depends_on = [
    aws_db_instance.db,
    aws_db_proxy.db,
    aws_db_proxy_target.rds_proxy,
    aws_secretsmanager_secret.db,
    aws_secretsmanager_secret_version.db
  ]
}