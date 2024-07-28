resource "aws_security_group" "ep" {
  name = "wsc2024-EP-SG"
  vpc_id = aws_vpc.prod.id

  ingress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "443"
    to_port = "443"
  }

  egress {
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "0"
    to_port = "0"
  }
 
    tags = {
    Name = "wsc2024-EP-SG"
  }
}

resource "aws_vpc_endpoint" "ecr" {
  vpc_id            = aws_vpc.prod.id
  service_name      = "com.amazonaws.us-east-1.ecr.dkr"
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.ep.id]
  private_dns_enabled = true

  tags = {
    Name = "wsc2024-ecr-endpoint"
  }
}

resource "aws_vpc_endpoint_subnet_association" "prod_a" {
  vpc_endpoint_id = aws_vpc_endpoint.ecr.id
  subnet_id       = aws_subnet.private_a.id
}
resource "aws_vpc_endpoint_subnet_association" "prod_b" {
  vpc_endpoint_id = aws_vpc_endpoint.ecr.id
  subnet_id       = aws_subnet.private_b.id
}

resource "aws_vpc_endpoint" "s3_ep" {
  vpc_id            = aws_vpc.prod.id
  service_name      = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowAll",
        "Effect" : "Allow",
        "Principal": "*",
        "Action" : "s3:*",
        "Resource": "arn:aws:s3:::prod-us-east-1-starport-layer-bucket/*",
        "Condition": {
          "IpAddress": {
            "aws:SourceIp": "${aws_instance.bastion.private_ip}/32"
            }
          }
      },
      {
        "Sid" : "AllowAll",
        "Effect" : "Allow",
        "Principal": "*",
        "Action" : "s3:*",
        "Resource": "*"
      }
    ]
  })
  
  tags = {
    Name = "wsc2024-s3-endpoint"
  }
}

resource "aws_vpc_endpoint_subnet_association" "prod_a1" {
  vpc_endpoint_id = aws_vpc_endpoint.ecr.id
  subnet_id       = aws_subnet.private_a.id
}
resource "aws_vpc_endpoint_subnet_association" "prod_b1 " {
  vpc_endpoint_id = aws_vpc_endpoint.ecr.id
  subnet_id       = aws_subnet.private_b.id
}