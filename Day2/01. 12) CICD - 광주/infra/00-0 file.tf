resource "random_string" "file_cicd_random" {
  length           = 3
  upper            = false
  lower            = false
  numeric          = true
  special          = false
}

resource "aws_s3_bucket" "app" {
  bucket = "app-${random_string.file_cicd_random.result}"
  force_destroy = true
}

resource "aws_s3_bucket" "manifest" {
  bucket = "app-manifest-${random_string.file_cicd_random.result}"
  force_destroy = true
}

resource "aws_s3_object" "buildspec" {
  bucket = aws_s3_bucket.app.id
  key    = "/buildspec.yaml"
  source = "./src/buildspec.yaml"
  etag   = filemd5("./src/buildspec.yaml")
  content_type = "application/vnd.yaml"
}

resource "aws_s3_object" "Docker" {
  bucket = aws_s3_bucket.app.id
  key    = "/Dockerfile"
  source = "./src/Dockerfile"
  etag   = filemd5("./src/Dockerfile")
}

resource "aws_s3_object" "app" {
  bucket = aws_s3_bucket.app.id
  key    = "/main.py"
  source = "./src/main.py"
  etag   = filemd5("./src/main.py")
}

resource "aws_s3_object" "deployment" {
  bucket = aws_s3_bucket.app.id
  key    = "/deployment.yaml"
  source = "./src/deployment.yaml"
  etag   = filemd5("./src/deployment.yaml")
}

resource "aws_s3_object" "kustomization" {
  bucket = aws_s3_bucket.app.id
  key    = "/kustomization.yaml"
  source = "./src/kustomization.yaml"
  etag   = filemd5("./src/kustomization.yaml")
}

resource "aws_s3_object" "requirements" {
  bucket = aws_s3_bucket.app.id
  key    = "/requirements.txt"
  source = "./src/requirements.txt"
  etag   = filemd5("./src/requirements.txt")
}

resource "aws_s3_object" "cluster" {
  bucket = aws_s3_bucket.manifest.id
  key    = "/cluster.yaml"
  source = "./manifest/cluster.yaml"
  etag   = filemd5("./manifest/cluster.yaml")
}