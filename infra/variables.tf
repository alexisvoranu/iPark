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

variable "jenkins_instance_type" {
  type        = string
  description = "The instance type for the Jenkins automation server"
}

variable "jenkins_volume_size" {
  type        = number
  description = "The root volume size for the Jenkins server in GB"
}

variable "stripe_api_key" {
  type      = string
  sensitive = true
}

variable "stripe_api_public_key" {
  type      = string
  sensitive = true
}

variable "stripe_webhook_secret" {
  type      = string
  sensitive = true
}

variable "url" {
  type      = string
  sensitive = true
}

variable "port" {
  type      = number
  sensitive = true
}