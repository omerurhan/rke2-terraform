module "vpc" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git?ref=v4.0.1"

  name = "${var.environment}-vpc"
  cidr = var.vpc_cidr
  azs             = local.azs
  enable_dns_hostnames = true
  
  public_subnets  = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k)]

  tags = var.tags
}

