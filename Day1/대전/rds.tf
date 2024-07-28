resource "aws_rds_global_cluster" "global" {
  global_cluster_identifier = "hrdkorea-rds"
  engine                    = "aurora-mysql"
  engine_version            = "8.0.mysql_aurora.3.05.2"
  database_name             = "hrdkorea-global"
}

resource "aws_rds_cluster" "primary" {
  provider                  = aws.seoul

  global_cluster_identifier = aws_rds_global_cluster.global.id
  cluster_identifier        = "hrdkorea-rds-instance"
  database_name             = "hrdkorea"
  db_subnet_group_name      = module.seoul.subnet_group
  vpc_security_group_ids    = [module.seoul.security_group]
  db_cluster_parameter_group_name = module.seoul.cluster_paramter_group
  db_instance_parameter_group_name = module.seoul.paramter_group
  engine                    = aws_rds_global_cluster.global.engine
  engine_version            = aws_rds_global_cluster.global.engine_version
  master_username           = "hrdkorea_user"
  master_password           = "Skill53##"
  enabled_cloudwatch_logs_exports  = ["audit", "error", "general", "slowquery"]
  skip_final_snapshot = true
  port = 3409
}

resource "aws_rds_cluster_instance" "primary" {
  provider             = aws.seoul

  cluster_identifier   = aws_rds_cluster.primary.id
  db_subnet_group_name = module.seoul.subnet_group
  db_parameter_group_name = module.seoul.paramter_group
  instance_class       = "db.r5.large"
  identifier           = "hrdkorea-rds-instance"
  engine               = aws_rds_global_cluster.global.engine
  engine_version       = aws_rds_global_cluster.global.engine_version
}

resource "aws_rds_cluster" "secondary" {
  provider                  = aws.usa

  global_cluster_identifier = aws_rds_global_cluster.global.id
  cluster_identifier        = "hrdkorea-rds-instance-us"
  db_subnet_group_name      = module.usa.subnet_group
  vpc_security_group_ids    = [module.usa.security_group]
  db_cluster_parameter_group_name = module.usa.cluster_paramter_group
  db_instance_parameter_group_name = module.usa.paramter_group
  engine                    = aws_rds_global_cluster.global.engine
  engine_version            = aws_rds_global_cluster.global.engine_version
  enabled_cloudwatch_logs_exports  = ["audit", "error", "general", "slowquery"]
  skip_final_snapshot = true
  enable_global_write_forwarding = true
  port = 3409
  
  depends_on = [
    aws_rds_cluster_instance.primary
  ]
}

resource "aws_rds_cluster_instance" "secondary" {
  provider             = aws.usa

  cluster_identifier   = aws_rds_cluster.secondary.id
  db_subnet_group_name = module.usa.subnet_group
  db_parameter_group_name = module.usa.paramter_group
  instance_class       = "db.r5.large"
  identifier           = "hrdkorea-rds-instance-us"
  engine               = aws_rds_global_cluster.global.engine
  engine_version       = aws_rds_global_cluster.global.engine_version
}

resource "aws_secretsmanager_secret" "seoul" {
  provider                  = aws.seoul

  name = "hrdkorea-secaret"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret" "usa" {
  provider                  = aws.usa

  name = "hrdkorea-secaret"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "seoul" {
  provider                  = aws.seoul

  secret_id     = aws_secretsmanager_secret.seoul.id
  secret_string = jsonencode({
    "username"            = aws_rds_cluster.primary.master_username
    "password"            = aws_rds_cluster.primary.master_password
    "engine"              = aws_rds_cluster.primary.engine
    "host"                = aws_rds_cluster.primary.endpoint
    "port"                = aws_rds_cluster.primary.port
    "dbClusterIdentifier" = aws_rds_cluster.primary.cluster_identifier
    "dbname"              = aws_rds_cluster.primary.database_name
    "aws_region"          = "ap-northeast-2"
  })
}

resource "aws_secretsmanager_secret_version" "usa" {
  provider                  = aws.usa

  secret_id     = aws_secretsmanager_secret.usa.id
  secret_string = jsonencode({
    "username"            = aws_rds_cluster.secondary.master_username
    "password"            = aws_rds_cluster.secondary.master_password
    "engine"              = aws_rds_cluster.secondary.engine
    "host"                = aws_rds_cluster.secondary.endpoint
    "port"                = aws_rds_cluster.secondary.port
    "dbClusterIdentifier" = aws_rds_cluster.secondary.cluster_identifier
    "dbname"              = aws_rds_cluster.secondary.database_name
    "aws_region"          = "us-east-1"
  })
}