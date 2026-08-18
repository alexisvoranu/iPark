variable "environment" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "port" {
  type = number
}

variable "execution_role_arn" {
  type = string
}

variable "alb_dns_name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "target_group_arn" {
  type = string
}

variable "alb_listener_arn" {
  type = any
}