## Import Module
### Seoul
module "seoul" {
    source = "./modules"
    create_region = "ap-northeast-2"
    destination_region = "us-east-1"   
    key_name = aws_key_pair.seoul_keypair.key_name
    
    providers = {
      aws = aws.seoul
    }
}

### Virginia
module "usa" {
    source = "./modules"
    create_region = "us-east-1"
    destination_region = "ap-northeast-2"
    key_name = aws_key_pair.usa_keypair.key_name

    providers = {
      aws = aws.usa
    }
}

### Keypair
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "seoul_keypair" {
  provider = aws.seoul

  key_name = "hrdkorea"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "aws_key_pair" "usa_keypair" {
  provider = aws.usa

  key_name = "hrdkorea"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "local_file" "keypair" {
  content = tls_private_key.rsa.private_key_pem
  filename = "./hrdkorea.pem"
}
