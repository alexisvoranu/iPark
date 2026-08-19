variable "environment" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "public_subnet_b_id" {
  type = string
}

variable "server_sg_id" {
  type = string
}

variable "github_actions_role_arn" {
  type        = string
  description = "IAM Role ARN used by GitHub Actions"
}

variable "eks_secrets_policy_arn" {
  type        = string
  description = "ARN-ul politicii IAM pentru accesul la secrete"
}