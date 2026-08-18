output "ecr_repository_url" {
  value = aws_ecr_repository.ipark_app_repo.repository_url
}

output "ecs_service_name" {
  value = aws_ecs_service.ipark_service.name
}