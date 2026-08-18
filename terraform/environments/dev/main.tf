module "vpc" {
  source               = "../../modules/vpc"
  environment          = var.environment
  aws_region           = var.aws_region
  cidr_block           = var.vpc_cidr
  public_subnet_a_cidr = var.public_subnet_a_cidr
  public_subnet_b_cidr = var.public_subnet_b_cidr
}

module "security" {
  source      = "../../modules/security"
  environment = var.environment
  vpc_id      = module.vpc.vpc_id
  port        = var.port
}

module "iam" {
  source      = "../../modules/iam"
  environment = var.environment
  github_repo = var.github_repo
}

module "eks" {
  source             = "../../modules/eks"
  environment        = var.environment
  subnet_ids         = module.vpc.public_subnet_ids
  security_group_id  = module.security.server_sg_id
  node_instance_type = "t3.medium"
  node_desired_size  = 1
  node_max_size      = 2
  node_min_size      = 1
}