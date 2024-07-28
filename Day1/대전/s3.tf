resource "random_string" "bucket_random_s3" {
  length           = 4
  upper            = false
  lower            = false
  numeric          = true
  special          = false
}
resource "aws_s3_bucket" "s3" {
  provider = aws.seoul

  bucket = "hrdkorea-static-${random_string.bucket_random_s3.result}"

    tags = {
        Name = "hrdkorea-static-${random_string.bucket_random_s3.result}"
    }
}

resource "aws_s3_bucket_object" "static_folder" {
  bucket = aws_s3_bucket.s3.bucket
  key = "static/"
}

resource "aws_s3_object" "static" {
  bucket = aws_s3_bucket.s3.id
  key    = "/static/index.html"
  source = "./src/index.html"
  etag   = filemd5("./src/index.html")
  content_type = "text/html"
}

resource "aws_s3_bucket_website_configuration" "source" {
  bucket = aws_s3_bucket.s3.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_versioning" "source" {
  provider = aws.seoul
  bucket   = aws_s3_bucket.s3.id
  versioning_configuration {
    status = "Enabled"
  }
}