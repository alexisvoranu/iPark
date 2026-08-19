output "ecs_execution_role_arn" {
  value = aws_iam_role.ecs_execution_role.arn
}

output "github_actions_role_arn" {
  value       = aws_iam_role.github_actions_role.arn
  description = "ARN of the IAM role used by GitHub Actions"
}

output "eks_secrets_policy_arn" {
  value = aws_iam_policy.eks_secrets_policy.arn
}