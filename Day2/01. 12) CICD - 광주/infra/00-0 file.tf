resource "random_string" "gwangju-cicd-file_cicd_random" {
  length           = 3
  upper            = false
  lower            = false
  numeric          = true
  special          = false
}

resource "aws_s3_bucket" "gwangju-cicd-app" {
  bucket = "app-${random_string.gwangju-cicd-file_cicd_random.result}"
  force_destroy = true
}

resource "aws_s3_bucket" "gwangju-cicd-manifest" {
  bucket = "app-manifest-${random_string.gwangju-cicd-file_cicd_random.result}"
  force_destroy = true
}

resource "aws_s3_object" "gwangju-cicd-buildspec" {
  bucket = aws_s3_bucket.gwangju-cicd-app.id
  key    = "/buildspec.yaml"
  source = "./src/gwangju-cicd/buildspec.yaml"
  etag   = filemd5("./src/gwangju-cicd/buildspec.yaml")
  content_type = "application/vnd.yaml"
}

resource "aws_s3_object" "gwangju-cicd-Docker" {
  bucket = aws_s3_bucket.gwangju-cicd-app.id
  key    = "/Dockerfile"
  source = "./src/gwangju-cicd/Dockerfile"
  etag   = filemd5("./src/gwangju-cicd/Dockerfile")
}

resource "aws_s3_object" "gwangju-cicd-app" {
  bucket = aws_s3_bucket.gwangju-cicd-app.id
  key    = "/main.py"
  source = "./src/gwangju-cicd/main.py"
  etag   = filemd5("./src/gwangju-cicd/main.py")
}

resource "aws_s3_object" "gwangju-cicd-deployment" {
  bucket = aws_s3_bucket.gwangju-cicd-app.id
  key    = "/deployment.yaml"
  source = "./src/gwangju-cicd/deployment.yaml"
  etag   = filemd5("./src/gwangju-cicd/deployment.yaml")
}

resource "aws_s3_object" "gwangju-cicd-kustomization" {
  bucket = aws_s3_bucket.gwangju-cicd-app.id
  key    = "/kustomization.yaml"
  source = "./src/gwangju-cicd/kustomization.yaml"
  etag   = filemd5("./src/gwangju-cicd/kustomization.yaml")
}

resource "aws_s3_object" "gwangju-cicd-requirements" {
  bucket = aws_s3_bucket.gwangju-cicd-app.id
  key    = "/requirements.txt"
  source = "./src/gwangju-cicd/requirements.txt"
  etag   = filemd5("./src/gwangju-cicd/requirements.txt")
}

resource "aws_s3_object" "gwangju-cicd-cluster" {
  bucket = aws_s3_bucket.gwangju-cicd-manifest.id
  key    = "/cluster.yaml"
  source = "./src/gwangju-cicd/manifest/cluster.yaml"
  etag   = filemd5("./src/gwangju-cicd/manifest/cluster.yaml")
}