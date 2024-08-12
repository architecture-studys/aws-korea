resource "aws_lb" "ecs" {
  name               = "apdev-ecs-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  tags = {
    Name = "apdev-ecs-alb"
  }
}

resource "aws_lb_listener" "ecs" {
  load_balancer_arn = aws_lb.ecs.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"

    forward {
      target_group {
        arn    = aws_alb_target_group.ecs-employee.arn
        weight = 50
      }

      target_group {
        arn    = aws_alb_target_group.ecs-token.arn
        weight = 50
      }
    }
  }
}

resource "aws_lb_listener_rule" "ecs-employee" {
  listener_arn = aws_lb_listener.ecs.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.ecs-employee.arn
  }

  condition {
    path_pattern {
      values = ["/v1/employee"]
    }
  }
}

resource "aws_lb_listener_rule" "ecs-token" {
  listener_arn = aws_lb_listener.ecs.arn
  priority     = 2

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.ecs-token.arn
  }

  condition {
    path_pattern {
      values = ["/v1/token"]
    }
  }
}

resource "aws_alb_target_group" "ecs-employee" {
  name     = "apdev-ecs-employee-tg"
  port     = 8080
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = aws_vpc.main.id
  deregistration_delay = 0

  health_check {
    path = "/healthcheck"
    port = 8080
    timeout = 2
    interval = 5
    unhealthy_threshold = 2
    healthy_threshold = 2
  }
  
  tags = {
    Name = "apdev-ecs-employee-tg"
  }
}

resource "aws_alb_target_group" "ecs-token" {
  name     = "apdev-ecs-token-tg"
  port     = 8080
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = aws_vpc.main.id
  deregistration_delay = 0

  health_check {
    path = "/healthcheck"
    port = 8080
    timeout = 2
    interval = 5
    unhealthy_threshold = 2
    healthy_threshold = 2
  }
  
  tags = {
    Name = "apdev-ecs-token-tg"
  }
}