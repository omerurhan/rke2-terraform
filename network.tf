module "vpc_upstream" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git?ref=v4.0.1"

  name = "vpc_upstream"
  cidr = local.vpc_cidr
  azs             = local.azs
  enable_dns_hostnames = true
  
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]

  tags = local.tags
}

