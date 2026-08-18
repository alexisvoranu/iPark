output "cluster_name" {
  value = aws_eks_cluster.ipark_eks.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.ipark_eks.endpoint
}

output "ecr_repository_url" {
  value = aws_ecr_repository.ipark_app_repo.repository_url
}