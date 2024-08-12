resource "aws_ecs_cluster" "cluster" {
  name = "apdev-ecs-cluster"

  tags = {
    Name = "apdev-ecs-cluster"
  }
}