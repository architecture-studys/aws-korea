resource "aws_ecr_repository" "ecr" {
  name = "apdev-ecr"

  image_scanning_configuration {
    scan_on_push = true
    }

    tags = {
        Name = "apdev-ecr"
    } 
}

output "ecr" {
    value = aws_ecr_repository.ecr.id
}