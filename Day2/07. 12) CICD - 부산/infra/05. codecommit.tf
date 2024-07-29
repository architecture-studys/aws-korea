resource "aws_codecommit_repository" "commit" {
    repository_name = "wsi-repo"

    default_branch = "main"
    
    lifecycle {
        ignore_changes = [default_branch]
    }

    tags = {
        Name = "wsi-repo"
    }
}