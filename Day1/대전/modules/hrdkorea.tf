resource "aws_vpc" "main" {
  cidr_block = "10.129.0.0/16"

  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "hrdkorea-vpc"
  }
}

# Public
## Internet Gateway
resource"aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "hrdkorea-IGW"
  }
}

## Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "hrdkorea-public-rt"
  }
}
data "aws_region" "current" {}
resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id
}

## Public Subnet
resource "aws_subnet" "public_a" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.129.0.0/24"
  availability_zone = "${var.create_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "hrdkorea-public-sn-a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.129.1.0/24"
  availability_zone = "${var.create_region}b"
  map_public_ip_on_launch = true

  tags = {
    Name = "hrdkorea-public-sn-b"
  }
}

## Attach Public Subnet in Route Table
resource "aws_route_table_association" "public_a" {
  subnet_id = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

# Private

## Elastic IP
resource "aws_eip" "private_a" {
}

resource "aws_eip" "private_b" {
}

## NAT Gateway
resource "aws_nat_gateway" "private_a" {
  depends_on = [aws_internet_gateway.main]

  allocation_id = aws_eip.private_a.id
  subnet_id = aws_subnet.public_a.id

  tags = {
    Name = "hrdkorea-NGW-a"
  }
}

resource "aws_nat_gateway" "private_b" {
  depends_on = [aws_internet_gateway.main]

  allocation_id = aws_eip.private_b.id
  subnet_id = aws_subnet.public_b.id

  tags = {
    Name = "hrdkorea-NGW-b"
  }
}

## Route Table
resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "hrdkorea-private-a-rt"
  }
}

resource "aws_route_table" "private_b" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "hrdkorea-private-b-rt"
  }
}

resource "aws_route" "private_a" {
  route_table_id = aws_route_table.private_a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.private_a.id
}

resource "aws_route" "private_b" {
  route_table_id = aws_route_table.private_b.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.private_b.id
}

resource "aws_subnet" "private_a" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.129.11.0/24"
  availability_zone = "${var.create_region}a"

  tags = {
    Name = "hrdkorea-private-sn-a"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.129.12.0/24"
  availability_zone = "${var.create_region}b"

  tags = {
    Name = "hrdkorea-private-sn-b"
  }
}

## Attach Private Subnet in Route Table
resource "aws_route_table_association" "private_a" {
  subnet_id = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_a.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_b.id
}

resource "aws_subnet" "protect_a" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.129.21.0/24"
  availability_zone = "${var.create_region}a"

  tags = {
    Name = "hrdkorea-protect-sn-a"
  }
}

resource "aws_subnet" "protect_b" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.129.22.0/24"
  availability_zone = "${var.create_region}b"

  tags = {
    Name = "hrdkorea-protect-sn-b"
  }
}
resource "aws_route_table_association" "protect_a" {
  subnet_id = aws_subnet.protect_a.id
  route_table_id = aws_route_table.protect_a.id
}

resource "aws_route_table_association" "protect_b" {
  subnet_id = aws_subnet.protect_a.id
  route_table_id = aws_route_table.protect_a.id
}


resource "aws_route_table" "protect_a" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "hrdkorea-protect-rt"
  }
}

# EC2
## AMI
data "aws_ssm_parameter" "latest_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-minimal-kernel-default-x86_64"
}

## Public EC2
resource "aws_instance" "bastion" {
  ami = data.aws_ssm_parameter.latest_ami.value
  subnet_id = aws_subnet.public_a.id
  instance_type = "t3.small"
  key_name = "${var.key_name}"
  vpc_security_group_ids = [aws_security_group.bastion.id]
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.bastion.name
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y jq curl wget zip
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    ln -s /usr/local/bin/aws /usr/bin/
    ln -s /usr/local/bin/aws_completer /usr/bin/
    sed -i "s|#PasswordAuthentication no|PasswordAuthentication yes|g" /etc/ssh/sshd_config
    echo "Port 2024" >> /etc/ssh/sshd_config
    systemctl restart sshd
    echo 'Skill53!@#' | passwd --stdin ec2-user
    echo 'Skill53!@#' | passwd --stdin root
    curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
    sudo mv /tmp/eksctl /usr/local/bin
    curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.29.3/2024-04-19/bin/linux/amd64/kubectl
    chmod +x kubectl
    mv kubectl /usr/local/bin
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
    mv get_helm.sh /usr/local/bin
    yum install -y docker
    systemctl enable --now docker
    usermod -aG docker ec2-user
    usermod -aG docker root
    chmod 666 /var/run/docker.sock
  EOF
  tags = {
    Name = "hrdkorea-bastion"
  }
}

## Public Security Group
resource "aws_security_group" "bastion" {
  name = "hrdkorea-EC2-SG"
  vpc_id = aws_vpc.main.id

  ingress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "2024"
    to_port = "2024"
  }

  egress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "443"
    to_port = "443"
  }

  egress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "80"
    to_port = "80"
  }

  egress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "3409"
    to_port = "3409"
  }

    tags = {
    Name = "hrdkorea-EC2-SG"
  }
}

resource "random_string" "random" {
  length           = 5
  upper            = false
  lower            = false
  numeric          = true
  special          = false
}

## IAM
resource "aws_iam_role" "bastion" {
  name = "hrdkorea-role-bastion${random_string.random.result}"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}

resource "aws_iam_instance_profile" "bastion" {
  name = "hrdkorea-profile-bastion${random_string.random.result}"
  role = aws_iam_role.bastion.name
}

# OutPut

## VPC
output "aws_vpc" {
  value = aws_vpc.main.id
}

## Public Subnet
output "public_a" {
  value = aws_subnet.public_a.id
}

output "public_b" {
  value = aws_subnet.public_b.id
}

## Private Subnet
output "private_a" {
  value = aws_subnet.private_a.id
}

output "private_b" {
  value = aws_subnet.private_b.id
}

output "protect_a" {
  value = aws_subnet.protect_a.id
}

output "protect_b" {
  value = aws_subnet.protect_b.id
}

output "bastion" {
  value = aws_instance.bastion.id
}

output "bastion-sg" {
  value = aws_security_group.bastion.id
}