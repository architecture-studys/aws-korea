resource "aws_instance" "bastion" {
  ami = data.aws_ssm_parameter.latest_ami.value
  subnet_id = aws_subnet.public_a.id
  instance_type = "t3.small"
  key_name = aws_key_pair.keypair.key_name
  vpc_security_group_ids = [aws_security_group.bastion.id]
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.bastion.name
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y jq curl wget zip
    dnf install -y mariadb105
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    ln -s /usr/local/bin/aws /usr/bin/
    ln -s /usr/local/bin/aws_completer /usr/bin/
    sed -i "s|#PasswordAuthentication no|PasswordAuthentication yes|g" /etc/ssh/sshd_config
    systemctl restart sshd
    echo 'Skill53##' | passwd --stdin ec2-user
    echo 'Skill53##' | passwd --stdin root
    yum install -y vim
    yum install -y wget
    yum install -y docker
    systemctl enable --now docker
    usermod -aG docker ec2-user
    usermod -aG docker root
    chmod 666 /var/run/docker.sock
    HOME=/home/ec2-user
    mkidr ~/image
    sudo chown ec2-user:ec2-user ~/image
    aws s3 cp s3://${aws_s3_bucket.app.id}/ ~/image --recursive
    chown ec2-user:ec2-user ~/image/*
    aws s3 rm s3://${aws_s3_bucket.app.id} --recursive
    aws s3 rb s3://${aws_s3_bucket.app.id} --force
    aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin ${data.aws_caller_identity.caller.account_id}.dkr.ecr.ap-northeast-2.amazonaws.com
    docker build -t ${aws_ecr_repository.ecr.repository_url}:employee ~/image/employee/
    docker build -t ${aws_ecr_repository.ecr.repository_url}:token ~/image/token/
    docker push ${aws_ecr_repository.ecr.repository_url}:employee
    docker push ${aws_ecr_repository.ecr.repository_url}:token
  EOF
  tags = {
    Name = "apdev-bastion"
  }
}

resource "aws_security_group" "bastion" {
  name = "apdev-bastion-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "22"
    to_port = "22"
  }

  egress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "22"
    to_port = "22"
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
    from_port = "443"
    to_port = "443"
  }

    tags = {
    Name = "apdev-bastion-sg"
  }
}

resource "aws_iam_role" "bastion" {
  name = "apdev-bastion-role"
  
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
  name = "apdev-profile-bastion"
  role = aws_iam_role.bastion.name
}