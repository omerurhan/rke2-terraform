module "cp_sg" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group.git?ref=v4.17.2"

  name        = "${var.environment}-cp-sg"
  description = "K8S API Server Access"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks  = [var.vpc_cidr, var.client_cidr]
  ingress_rules        = ["kubernetes-api-tcp"]

   tags = var.tags
}

module "node_sg" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group.git?ref=v4.17.2"

  name = "${var.environment}-node-sg"
  description = "K8S Node to Node Acccess"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks  = [var.vpc_cidr]
  ingress_rules        = ["all-all"]

  egress_cidr_blocks  = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]

  tags = var.tags
}

module ssh_sg {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group.git?ref=v4.17.2"

  name = "${var.environment}-ssh"
  description = "Client SSH Access"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks  = ["0.0.0.0/0"]
  ingress_rules        = ["ssh-tcp"]

  tags = var.tags

}