terraform {
  backend "s3" {
    bucket       = "ipark-terraform-state-bucket"
    region       = "eu-central-1"
    use_lockfile = true
    encrypt      = true
  }
}