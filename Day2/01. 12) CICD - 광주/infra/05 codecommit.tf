resource "aws_codecommit_repository" "commit" {
    repository_name = "gwangju-application-repo"
    default_branch = "master"
    
    lifecycle {
        ignore_changes = [default_branch]
    }
    
    tags = {
      Name = "gwangju-application-repo"
    } 
}