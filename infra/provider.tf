terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "ipark-terraform-state-bucket"
    key            = "dev/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "ipark-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}