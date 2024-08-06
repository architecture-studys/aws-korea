resource "aws_security_group" "alb" {
  name        = "apdev-ALB-SG"
  description = "apdev-ALB-SG"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol   = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port  = 80
    to_port    = 80
  }

  egress {
    protocol   = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "apdev-ASG-SG"
  }
}

resource "aws_lb" "alb" {
  name               = "apdev-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.app_a.id, aws_subnet.app_b.id]

  tags = {
    Name = "apdev-alb"
  }
}

resource "aws_lb_target_group" "alb" {
  name        = "apdev-alb-tg"
  port        = 8080
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id

  health_check {
    port                = 8080
    interval            = 10
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    path                = "/healthcheck"
  }

  tags = {
    Name = "apdev-alb-tg"
  }
}


resource "aws_lb_target_group_attachment" "alb-app1" {
  target_group_arn = aws_lb_target_group.alb.arn
  target_id        = aws_instance.app1.id
  port             = 8080

  depends_on       = [aws_instance.app1]
}

resource "aws_lb_target_group_attachment" "alb-app2" {
  target_group_arn = aws_lb_target_group.alb.arn
  target_id        = aws_instance.app2.id
  port             = 8080

  depends_on       = [aws_instance.app2]
}