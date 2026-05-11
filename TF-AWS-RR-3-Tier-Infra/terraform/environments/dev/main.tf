resource "random_password" "db_password" {
  length  = 16
  special = true
  # Exclude characters that might cause issues in connection strings
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

module "vpc" {
  source = "../../modules/vpc"

  environment                = var.environment
  project                    = var.project
  enable_nat_gateway         = true
  single_nat_gateway         = var.single_nat_gateway
  vpc_cidr                   = var.vpc_cidr
  public_subnet_cidrs        = var.public_subnet_cidrs
  web_subnet_cidrs           = var.web_subnet_cidrs
  database_subnet_cidrs      = var.database_subnet_cidrs
  availability_zones         = var.availability_zones
  subnet_az_mapping          = var.subnet_az_mapping
  tags                       = var.tags
}

module "security_groups" {
  source = "../../modules/security-groups"

  environment = var.environment
  project     = var.project
  vpc_id      = module.vpc.vpc_id
  tags        = var.tags
}

module "s3" {
  source = "../../modules/s3"

  bucket_name   = var.bucket_name
  environment   = var.environment
  project       = var.project
  bucket_suffix = var.bucket_suffix
  tags          = var.tags
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

  tags = var.tags
}

module "iam" {
  source = "../../modules/iam"

  s3_bucket_arn = module.s3.bucket_arn
  environment   = var.environment
  project       = var.project
  secrets_arns  = ["*"]

  tags = var.tags
}

module "alb" {
  source = "../../modules/alb"

  environment       = var.environment
  project           = var.project
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.public_subnet_ids
  security_group_id = module.security_groups.alb_sg_id
  target_group_port = 5000

  tags = var.tags
}

module "asg" {
  source = "../../modules/asg"

  environment          = var.environment
  project              = var.project
  region               = var.region
  instance_type        = var.webapp_instance_type
  key_name             = var.ssh_key_name
  iam_instance_profile = module.iam.ec2_instance_profile_name
  security_group_id    = module.security_groups.web_sg_id
  subnet_ids           = module.vpc.web_subnet_ids
  target_group_arn     = module.alb.target_group_arn
  bucket_name          = module.s3.bucket_name
  min_size             = var.webapp_min_size
  max_size             = var.webapp_max_size
  desired_capacity     = var.webapp_desired_capacity

  tags = var.tags

  depends_on = [module.rds, module.alb]
}
