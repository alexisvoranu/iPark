output "ecr_repository_url" {
  value       = aws_ecr_repository.ipark_app_repo.repository_url
  description = "The URL of the ECR repository"
}

output "alb_dns_name" {
  value       = aws_lb.ipark_alb.dns_name
  description = "The permanent URL to access the application"
}