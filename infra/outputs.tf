output "ecr_repository_url" {
  value       = aws_ecr_repository.ipark_app_repo.repository_url
  description = "The URL of the ECR repository"
}