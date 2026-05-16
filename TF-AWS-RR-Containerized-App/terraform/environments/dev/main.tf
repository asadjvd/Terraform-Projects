resource "random_password" "db_password" {
  length  = 16
  special = true
  # Exclude characters that might cause issues in connection strings
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

module "vpc" {
  source = "../../modules/vpc"

  environment           = var.environment
  project               = var.project
  enable_nat_gateway    = true
  single_nat_gateway    = var.single_nat_gateway
  vpc_cidr              = var.vpc_cidr
  public_subnet_cidrs   = var.public_subnet_cidrs
  webapp_subnet_cidrs   = var.webapp_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
  availability_zones    = var.availability_zones
  subnet_az_mapping     = var.subnet_az_mapping
  tags                  = var.tags
}

module "security_groups" {
  source = "../../modules/security-groups"

  environment = var.environment
  project     = var.project
  vpc_id      = module.vpc.vpc_id
  tags        = var.tags
}

module "rds" {
  source = "../../modules/rds"

  environment             = var.environment
  project                 = var.project
  subnet_ids              = module.vpc.database_subnet_ids
  security_group_id       = module.security_groups.database_sg_id
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  engine_version          = var.db_engine_version
  db_name                 = var.db_name
  db_username             = var.db_username
  db_password             = random_password.db_password.result
  db_multi_az             = var.db_multi_az
  backup_retention_period = var.db_backup_retention
  skip_final_snapshot     = var.db_skip_final_snapshot
  tags                    = var.tags
}

module "secrets" {
  source = "../../modules/secrets"

  environment = var.environment
  project     = var.project
  db_username = var.db_username
  db_password = random_password.db_password.result
  db_host     = module.rds.db_address
  db_port     = module.rds.db_port
  db_name     = var.db_name
  tags        = var.tags
}

module "iam" {
  source = "../../modules/iam"

  environment  = var.environment
  project      = var.project
  secrets_arns = [module.secrets.db_secret_arn]
  tags         = var.tags
}

module "ecr" {
  source = "../../modules/ecr"

  environment        = var.environment
  project            = var.project
  frontend_repo_name = var.frontend_repo_name
  backend_repo_name  = var.backend_repo_name
}

module "ec2" {
  source = "../../modules/ec2"

  environment          = var.environment
  project              = var.project
  key_name             = var.ssh_key_name
  region               = var.region
  instance_type        = var.instance_type
  frontend             = var.frontend
  backend              = var.backend
  frontend_repo_name   = var.frontend_repo_name
  backend_repo_name    = var.backend_repo_name
  frontend_url         = var.frontend_url
  backend_url          = var.backend_url
  subnet_id            = module.vpc.webapp_subnet_ids["webapp-subnet-1a"]
  iam_instance_profile = module.iam.ec2_instance_profile_name
  security_group_id    = module.security_groups.webapp_sg_id
  tags                 = var.tags

  depends_on = [module.ecr, module.rds]
}

module "alb" {
  source = "../../modules/alb"

  environment       = var.environment
  project           = var.project
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = values(module.vpc.public_subnet_ids)
  security_group_id = module.security_groups.alb_sg_id
  tags              = var.tags
}

module "ecs" {
  source = "../../modules/ecs"

  environment               = var.environment
  project                   = var.project
  execution_role_arn        = module.iam.ecs_task_execution_role_arn
  frontend_image            = module.ecr.frontend_repo_url
  backend_image             = module.ecr.backend_repo_url
  secret_arn                = module.secrets.db_secret_arn
  webapp_subnet_ids         = values(module.vpc.webapp_subnet_ids)
  security_group_id         = module.security_groups.webapp_sg_id
  frontend_target_group_arn = module.alb.frontend_target_group_arn
  backend_target_group_arn  = module.alb.backend_target_group_arn
  frontend_listener_arn     = module.alb.frontend_listener_arn
  backend_listener_arn      = module.alb.backend_listener_arn
  tags                      = var.tags
}