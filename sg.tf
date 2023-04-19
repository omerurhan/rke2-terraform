module "cp_sg" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group.git?ref=v4.17.2"

  name        = "cp-sg"
  description = "K8S API Server Access"
  vpc_id      = module.vpc_upstream.vpc_id

  ingress_cidr_blocks  = [local.vpc_cidr, local.client_cidr]
  ingress_rules        = ["kubernetes-api-tcp"]

   tags = local.tags
}

module "node_sg" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group.git?ref=v4.17.2"

  name = "node-sg"
  description = "K8S Node to Node Acccess"
  vpc_id      = module.vpc_upstream.vpc_id

  ingress_cidr_blocks  = [local.vpc_cidr]
  ingress_rules        = ["all-all"]

  egress_cidr_blocks  = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]

  tags = local.tags
}

module ssh_sg {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group.git?ref=v4.17.2"

  name = "ssh"
  description = "Client SSH Access"
  vpc_id      = module.vpc_upstream.vpc_id

  ingress_cidr_blocks  = ["0.0.0.0/0"]
  ingress_rules        = ["ssh-tcp"]

  tags = local.tags

}