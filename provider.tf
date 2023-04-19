provider "aws" {
  region = local.region
}

locals {
  region = "eu-central-1"
  client_cidr = "178.233.138.61/32"
  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  ami = "ami-0968bb84a3c33d0be"
  instance_type = "t3.medium"
  key_name = "dev-key"

  tags = {
    GithubRepo = "terraform-aws-alb"
    GithubOrg  = "terraform-aws-modules"
    Owner       = "user"
    Environment = "dev"
  }
}