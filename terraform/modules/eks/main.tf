resource "aws_ecr_repository" "ipark_app_repo" {
  name                 = "ipark-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.environment}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_eks_cluster" "ipark_eks" {
  name     = "${var.environment}-ipark-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.31"

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_public_access  = true
    endpoint_private_access = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

resource "aws_iam_role" "eks_node_role" {
  name = "${var.environment}-eks-node-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_registry_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_eks_node_group" "nodes" {
  cluster_name    = aws_eks_cluster.ipark_eks.name
  node_group_name = "${var.environment}-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.subnet_ids
  instance_types  = [var.node_instance_type]
  version         = "1.31"
  ami_type        = "AL2023_x86_64_STANDARD"

  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_registry_policy
  ]
}

resource "aws_eks_access_entry" "console_admin_access" {
  cluster_name  = aws_eks_cluster.ipark_eks.name
  principal_arn = "arn:aws:iam::833333701463:root"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "console_admin_policy" {
  cluster_name  = aws_eks_cluster.ipark_eks.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_eks_access_entry.console_admin_access.principal_arn

  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_access_entry" "github_actions_access" {
  cluster_name  = aws_eks_cluster.ipark_eks.name
  principal_arn = "arn:aws:iam::833333701463:role/${var.environment}-ipark-github-actions-role"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "github_actions_policy" {
  cluster_name  = aws_eks_cluster.ipark_eks.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_eks_access_entry.github_actions_access.principal_arn

  access_scope {
    type = "cluster"
  }
}