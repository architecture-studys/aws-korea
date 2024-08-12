resource "random_string" "file_random" {
  length           = 3
  upper            = false
  lower            = false
  numeric          = true
  special          = false
}

resource "aws_s3_bucket" "app" {
  bucket = "app-${random_string.file_random.result}"
  force_destroy = true
}

resource "aws_s3_object" "employee-Dockerfile" {
  bucket = aws_s3_bucket.app.id
  key    = "/employee/Dockerfile"
  source = "./src/employee/Dockerfile"
  etag   = filemd5("./src/employee/Dockerfile")
}

resource "aws_s3_object" "employee-app" {
  bucket = aws_s3_bucket.app.id
  key    = "/employee/employee"
  source = "./src/employee/employee"
  etag   = filemd5("./src/employee/employee")
}

resource "aws_s3_object" "token-Dockerfile" {
  bucket = aws_s3_bucket.app.id
  key    = "/token/Dockerfile"
  source = "./src/token/Dockerfile"
  etag   = filemd5("./src/token/Dockerfile")
}

resource "aws_s3_object" "token-app" {
  bucket = aws_s3_bucket.app.id
  key    = "/token/token"
  source = "./src/token/token"
  etag   = filemd5("./src/token/token")
}