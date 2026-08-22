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
  source      = "./modules/iam"
  environment = var.environment
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
}

resource "aws_secretsmanager_secret" "app_secrets" {
  name                    = "ipark/${var.environment}/secrets"
  recovery_window_in_days = 0
}

resource "aws_ecr_repository" "ipark_app" {
  name                 = "${var.environment}-ipark-app"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

resource "kubernetes_service" "ipark_service" {
  metadata {
    name   = "ipark-service"
    labels = {
      app = "ipark-backend"
    }
  }

  spec {
    selector = {
      app = "ipark-backend"
    }

    port {
      port        = 80
      target_port = 8080
    }

    type = "LoadBalancer"
  }

  depends_on = [
    module.eks
  ]
}