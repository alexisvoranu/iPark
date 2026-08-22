output "ecr_repository_url" {
  value       = aws_ecr_repository.ipark_app.repository_url
  description = "The URL of the ECR repository"
}

output "service_status" {
  description = "Status of the deployed Kubernetes Service"
  value       = kubernetes_service.ipark_service.status
}