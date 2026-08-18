output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "ecr_repository_url" {
  value = module.ecs.ecr_repository_url
}

output "github_actions_role_arn" {
  value = module.iam.github_actions_role_arn
}