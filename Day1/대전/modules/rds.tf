resource "aws_security_group" "db" {
  name        = "hrdkorea-RDS-SG"
  description = "hrdkorea-RDS-SG"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol   = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
    from_port  = 3409
    to_port    = 3409
  }

  egress {
    protocol   = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "hrdkorea-RDS-SG"
  }
}

resource "aws_db_subnet_group" "db" {
    name = "hrdkorea-rds-sg"
    subnet_ids = [
        aws_subnet.protect_a.id,
        aws_subnet.protect_b.id
    ]
    
    tags = {
        Name = "hrdkorea--rds-sg"
    }
}

resource "aws_rds_cluster_parameter_group" "db" {
  name        = "hrdkorea-rds-cpg"
  description = "hrdkorea-rds-cpg"
  family      = "aurora-mysql8.0"

  parameter {
    name  = "time_zone"
    value = "Asia/Seoul"
  }

  tags = {
    Name = "hrdkorea-rds-cpg"
  }
}

resource "aws_db_parameter_group" "db" {
  name        = "hrdkorea-rds-pg"
  description = "hrdkorea-rds-pg"
  family      = "aurora-mysql8.0"

  tags = {
    Name = "hrdkorea-rds-pg"
  }
}

output "subnet_group" {
  value = aws_db_subnet_group.db.id
}

output "security_group" {
  value = aws_security_group.db.id
}

output "cluster_paramter_group" {
  value = aws_rds_cluster_parameter_group.db.id
}

output "paramter_group" {
  value = aws_db_parameter_group.db.id
}
