output "github_actions_role_arn" {
  value = aws_iam_role.github_actions_role.arn
}

output "secrets_arn" {
  value = aws_secretsmanager_secret.app_secrets.arn
}