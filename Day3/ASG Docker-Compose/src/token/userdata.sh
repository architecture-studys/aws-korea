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
sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
HOME=/home/ec2-user
S3_BUCKET_NAME=$(aws s3api list-buckets --query "Buckets[?contains(Name, 'token')].Name" --output text)
aws s3 cp s3://$S3_BUCKET_NAME/token/ ~/ --recursive
SECRET_NAME=$(aws secretsmanager list-secrets --query "SecretList[?Name=='rds-secret'].Name" --output text)
MYSQL_USER=$(aws secretsmanager get-secret-value --secret-id $SECRET_NAME --query "SecretString" --output text | jq -r ".username")
MYSQL_PASSWORD=$(aws secretsmanager get-secret-value --secret-id $SECRET_NAME --query "SecretString" --output text | jq -r ".password")
MYSQL_HOST=$(aws secretsmanager get-secret-value --secret-id $SECRET_NAME --query "SecretString" --output text | jq -r ".proxy_host")
MYSQL_PORT=$(aws secretsmanager get-secret-value --secret-id $SECRET_NAME --query "SecretString" --output text | jq -r ".proxy_port")
MYSQL_DBNAME=$(aws secretsmanager get-secret-value --secret-id $SECRET_NAME --query "SecretString" --output text | jq -r ".dbname")
sed -i "s|dbusername|$MYSQL_USER|" ~/docker-compose.yaml
sed -i "s|dbpassword|$MYSQL_PASSWORD|" ~/docker-compose.yaml
sed -i "s|dbhost|$MYSQL_HOST|" ~/docker-compose.yaml
sed -i "s|dbport|$MYSQL_PORT|" ~/docker-compose.yaml
sed -i "s|dbname|$MYSQL_DBNAME|" ~/docker-compose.yaml
docker-compose -f ~/docker-compose.yaml up -d