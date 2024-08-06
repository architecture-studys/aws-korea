resource "aws_instance" "app1" {
  ami = data.aws_ssm_parameter.latest_ami.value
  subnet_id = aws_subnet.app_a.id
  instance_type = "t3.micro"
  key_name = aws_key_pair.keypair.key_name
  vpc_security_group_ids = [aws_security_group.app.id]
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.app.name
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
    yum install -y docker
    systemctl enable --now docker
    usermod -aG docker ec2-user
    usermod -aG docker root
    chmod 666 /var/run/docker.sock
  EOF
  tags = {
    Name = "apdev-app1"
  }
}

resource "aws_instance" "app2" {
  ami = data.aws_ssm_parameter.latest_ami.value
  subnet_id = aws_subnet.app_b.id
  instance_type = "t3.micro"
  key_name = aws_key_pair.keypair.key_name
  vpc_security_group_ids = [aws_security_group.app.id]
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.app.name
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
    yum install -y docker
    systemctl enable --now docker
    usermod -aG docker ec2-user
    usermod -aG docker root
    chmod 666 /var/run/docker.sock
  EOF
  tags = {
    Name = "apdev-app2"
  }
}