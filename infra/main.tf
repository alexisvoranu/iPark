module "vpc" {
  source               = "./modules/vpc"
  environment          = var.environment
  aws_region           = var.aws_region
  cidr_block           = var.vpc_cidr
  public_subnet_a_cidr = var.public_subnet_a_cidr
  public_subnet_b_cidr = var.public_subnet_b_cidr
}

module "security" {
  source      = "./modules/security"
  environment = var.environment
  vpc_id      = module.vpc.vpc_id
  port        = var.port
}

module "alb" {
  source            = "./modules/alb"
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.public_subnet_ids
  security_group_id = module.security.server_sg_id
  port              = var.port
}

module "iam" {
  source      = "./modules/iam"
  environment = var.environment
  github_repo = var.github_repo
}

module "ecs" {
  source             = "./modules/ecs"
  environment        = var.environment
  aws_region         = var.aws_region
  port               = var.port
  execution_role_arn = module.iam.ecs_execution_role_arn
  alb_dns_name       = module.alb.alb_dns_name
  subnet_id          = module.vpc.public_subnet_a_id
  security_group_id  = module.security.server_sg_id
  target_group_arn   = module.alb.target_group_arn
  alb_listener_arn   = module.alb.listener_arn
}