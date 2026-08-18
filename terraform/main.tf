module "vpc" {
  source               = "./modules/vpc"
  environment          = var.environment
  aws_region           = var.aws_region
  vpc_cidr             = var.vpc_cidr
  cidr_block           = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  public_subnet_a_cidr = var.public_subnet_cidrs[0]
  public_subnet_b_cidr = var.public_subnet_cidrs[1]
  availability_zones   = var.availability_zones
}

module "security" {
  source      = "./modules/security"
  environment = var.environment
  vpc_id      = module.vpc.vpc_id
  port        = 8080
}

module "eks" {
  source             = "./modules/eks"
  environment        = var.environment
  subnet_ids         = module.vpc.public_subnet_ids
  security_group_id  = module.security.server_sg_id
  k8s_version        = var.k8s_version
  node_instance_type = var.node_instance_type
  node_desired_size  = var.node_desired_size
  node_max_size      = var.node_max_size
  node_min_size      = var.node_min_size
}