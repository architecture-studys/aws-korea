resource "random_string" "gwangju-cicd-file_cicd_random" {
  length           = 3
  upper            = false
  lower            = false
  numeric          = true
  special          = false
}

resource "aws_s3_bucket" "employee" {
  bucket = "employee-${random_string.gwangju-cicd-file_cicd_random.result}"
  force_destroy = true
}

resource "aws_s3_object" "employee-Dockerfile" {
  bucket = aws_s3_bucket.employee.id
  key    = "/employee/Dockerfile"
  source = "./src/employee/Dockerfile"
  etag   = filemd5("./src/employee/Dockerfile")
}

resource "aws_s3_object" "employee-app" {
  bucket = aws_s3_bucket.employee.id
  key    = "/employee/employee"
  source = "./src/employee/employee"
  etag   = filemd5("./src/employee/employee")
}

resource "aws_s3_object" "employee-Docker-Compose" {
  bucket = aws_s3_bucket.employee.id
  key    = "/employee/docker-compose.yaml"
  source = "./src/employee/docker-compose.yaml"
  etag   = filemd5("./src/employee/docker-compose.yaml")
}

resource "aws_s3_bucket" "token" {
  bucket = "token-${random_string.gwangju-cicd-file_cicd_random.result}"
  force_destroy = true
}

resource "aws_s3_object" "token-Dockerfile" {
  bucket = aws_s3_bucket.token.id
  key    = "/token/Dockerfile"
  source = "./src/token/Dockerfile"
  etag   = filemd5("./src/token/Dockerfile")
}

resource "aws_s3_object" "token-app" {
  bucket = aws_s3_bucket.token.id
  key    = "/token/token"
  source = "./src/token/token"
  etag   = filemd5("./src/token/token")
}

resource "aws_s3_object" "token-Docker-Compose" {
  bucket = aws_s3_bucket.token.id
  key    = "/token/docker-compose.yaml"
  source = "./src/token/docker-compose.yaml"
  etag   = filemd5("./src/token/docker-compose.yaml")
}