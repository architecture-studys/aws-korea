resource "aws_ecr_repository" "ecr" {
  name = "wsi-repo"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
    }

    tags = {
        Name = "wsi-repo"
    }
}