resource "aws_security_group" "rds" {
  name = "skills-RDS-SG"
  vpc_id = aws_vpc.main.id

  ingress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "3306"
    to_port = "3306"
  }

  egress {
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "0"
    to_port = "0"
  }
 
    tags = {
    Name = "skills-RDS-SG"
  }
}

resource "aws_security_group" "controlplan" {
  name = "skills-EKS-ControlPlan-SG"
  vpc_id = aws_vpc.main.id

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
    Name = "skills-controlplan-SG"
  }
}

output "rds" {
    value = aws_security_group.rds.id
}

output "controlplan" {
    value = aws_security_group.controlplan.id
}