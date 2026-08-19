resource "aws_secretsmanager_secret" "app_secrets" {
  name                    = "ipark/${var.environment}/secrets"
  recovery_window_in_days = 0
}

resource "aws_ecr_repository" "ipark_app" {
  name         = "ipark-app"
  force_delete = true
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

module "eks" {
  source                  = "./modules/eks"
  environment             = var.environment
  aws_region              = var.aws_region
  vpc_id                  = module.vpc.vpc_id
  public_subnet_id        = module.vpc.public_subnet_id
  public_subnet_b_id      = module.vpc.public_subnet_b_id
  server_sg_id            = module.security.server_sg_id
  github_actions_role_arn = module.iam.github_actions_role_arn
  eks_secrets_policy_arn  = module.iam.eks_secrets_policy_arn
}

