variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "environment" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "availability_zones" {
  type = list(string)
}

variable "k8s_version" {
  type    = string
  default = "1.31"
}

variable "node_instance_type" {
  type = string
}

variable "node_desired_size" {
  type = number
}

variable "node_max_size" {
  type = number
}

variable "node_min_size" {
  type = number
}