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

variable "ecs_execution_role_arn" {
  type = string
}

variable "app_secrets_arn" {
  type = string
}

variable "port" {
  type = number
}