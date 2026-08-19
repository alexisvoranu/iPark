resource "aws_secretsmanager_secret" "app_secrets" {
  name                    = "ipark/production/secrets"
  recovery_window_in_days = 0
}

module "vpc" {
  source      = "./modules/vpc"
  environment = var.environment
  aws_region  = var.aws_region
}

module "security" {
  source      = "./modules/security"
  environment = var.environment
  vpc_id      = module.vpc.vpc_id
}

module "iam" {
  source          = "./modules/iam"
  environment     = var.environment
  app_secrets_arn = aws_secretsmanager_secret.app_secrets.arn
}

module "ecs" {
  source                 = "./modules/ecs"
  environment            = var.environment
  aws_region             = var.aws_region
  vpc_id                 = module.vpc.vpc_id
  public_subnet_id       = module.vpc.public_subnet_id
  public_subnet_b_id     = module.vpc.public_subnet_b_id
  server_sg_id           = module.security.server_sg_id
  ecs_execution_role_arn = module.iam.ecs_execution_role_arn
  app_secrets_arn        = aws_secretsmanager_secret.app_secrets.arn
  port                   = var.port
}