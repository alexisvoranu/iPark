variable "aws_region" {
  type        = string
  description = "The AWS region where resources will be created"
}

variable "environment" {
  type        = string
  description = "The environment name tag used to identify resources"
}

variable "instance_type" {
  type        = string
  description = "The size of the EC2 instance to host our tools"
}

variable "ssh_public_key" {
  type        = string
  description = "The public SSH key used to connect to the EC2 instance"
}