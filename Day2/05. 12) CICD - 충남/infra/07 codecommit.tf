resource "aws_codecommit_repository" "commit" {
    repository_name = "wsc2024-cci"
    default_branch = "master"
  
    lifecycle {
        ignore_changes = [default_branch]
    }

    tags = {
        Name = "wsc2024cci"
    }
}