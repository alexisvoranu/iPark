data "aws_iam_openid_connect_provider" "existing_github" {
  count = var.environment == "prod" ? 1 : 0
  url   = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github" {
  count           = var.environment == "dev" ? 1 : 0
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c587692c60e71e49ec65163d778570a42130c61"]
}

locals {
  github_oidc_arn = var.environment == "dev" ? aws_iam_openid_connect_provider.github[0].arn : data.aws_iam_openid_connect_provider.existing_github[0].arn
}

resource "aws_iam_role" "github_actions_role" {
  name = "${var.environment}-ipark-github-actions-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Federated = local.github_oidc_arn
        }
        Action    = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:alexisvoranu/iPark:*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "admin_access" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}