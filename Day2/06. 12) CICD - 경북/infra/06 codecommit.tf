resource "aws_codecommit_repository" "commit" {
    repository_name = "wsi-commit"

    default_branch = "main"
    
    lifecycle {
        ignore_changes = [default_branch]
    }
}