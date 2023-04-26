data "aws_availability_zones" "available" {}

module "ec2_instance_cp" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-ec2-instance.git?ref=v4.3.0"

  count = var.cp_count
  name = "${var.environment}-cp-${count.index}"
  #create_spot_instance = true
  associate_public_ip_address = true

  ami                    = var.ami
  instance_type          = var.instance_type
  iam_instance_profile   = aws_iam_instance_profile.loki_profile.name
  key_name               = var.key_name
  monitoring             = true
  vpc_security_group_ids = [module.cp_sg.security_group_id, module.node_sg.security_group_id, module.ssh_sg.security_group_id]
  subnet_id              = element(module.vpc.public_subnets, count.index)

  root_block_device = [
    {
      volume_type = "gp3"
      volume_size = 40
    },
  ]
}

module "ec2_instance_worker" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-ec2-instance.git?ref=v4.3.0"

  count = var.worker_count

  name = "${var.environment}-worker-${count.index}"
  #create_spot_instance = true
  associate_public_ip_address = true

  ami                    = var.ami
  instance_type          = var.instance_type
  iam_instance_profile   = aws_iam_instance_profile.loki_profile.name
  key_name               = var.key_name
  monitoring             = true
  vpc_security_group_ids = [module.node_sg.security_group_id, module.ssh_sg.security_group_id]
  subnet_id              = element(module.vpc.public_subnets, count.index)

  root_block_device = [
    {
      volume_type = "gp3"
      volume_size = 40
    },
  ]

  ebs_block_device = [
   {
     device_name = "/dev/sdb"
     volume_type = "gp3"
     volume_size = 30
   }
  ]

  tags = var.tags
}

module "nlb_cp" {
  source  = "git::https://github.com/terraform-aws-modules/terraform-aws-alb.git?ref=v8.6.0"

  name = "${var.environment}-nlb-cp"
  load_balancer_type = "network"
  vpc_id  = module.vpc.vpc_id
  internal = false
  subnets = module.vpc.public_subnets
  

  #subnet_mapping = [for i, eip in aws_eip.this : { allocation_id : eip.id, subnet_id : module.vpc.public_subnets[i] }]
  

  http_tcp_listeners = [
    {
      port               = 6443
      protocol           = "TCP"
      target_group_index = 0
    },
    {
      port               = 9345
      protocol           = "TCP"
      target_group_index = 1
    },
    {
      port               = 80
      protocol           = "TCP"
      target_group_index = 2
    },
    {
      port               = 443
      protocol           = "TCP"
      target_group_index = 3
    }
  ]

  target_groups = [
    {
      name_prefix      = "cp-"
      backend_protocol = "TCP"
      backend_port     = 6443
      target_type      = "instance"
      preserve_client_ip = false
      health_check = {
        enabled             = true
        interval            = 10
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 6
        protocol            = "TCP"
      }
    },
    {
      name_prefix      = "agent-"
      backend_protocol = "TCP"
      backend_port     = 9345
      target_type      = "instance"
      preserve_client_ip = false
      health_check = {
        enabled             = true
        interval            = 10
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 6
        protocol            = "TCP"
      }
    },
    {
      name_prefix      = "in-80"
      backend_protocol = "TCP"
      backend_port     = 80
      target_type      = "instance"
      preserve_client_ip = false
      health_check = {
        enabled             = true
        interval            = 10
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 6
        protocol            = "TCP"
      }
    },
    {
      name_prefix      = "in-443"
      backend_protocol = "TCP"
      backend_port     = 443
      target_type      = "instance"
      preserve_client_ip = false
      health_check = {
        enabled             = true
        interval            = 10
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 6
        protocol            = "TCP"
      }
    }
    
  ]

  tags = var.tags
/*  access_logs = {
    bucket = "my-access-logs-bucket"
  }
*/
}

resource "aws_lb_target_group_attachment" "cp" {
  count = length(module.ec2_instance_cp)
  target_group_arn = module.nlb_cp.target_group_arns[0]
  target_id        = module.ec2_instance_cp[count.index].id
  port             = 6443
}

resource "aws_lb_target_group_attachment" "agent" {
  count = length(module.ec2_instance_cp)
  target_group_arn = module.nlb_cp.target_group_arns[1]
  target_id        = module.ec2_instance_cp[count.index].id
  port             = 9345
}

resource "aws_lb_target_group_attachment" "ingress-80" {
  count = length(module.ec2_instance_worker)
  target_group_arn = module.nlb_cp.target_group_arns[2]
  target_id        = module.ec2_instance_worker[count.index].id
  port             = 80
}

resource "aws_lb_target_group_attachment" "ingress-443" {
  count = length(module.ec2_instance_worker)
  target_group_arn = module.nlb_cp.target_group_arns[3]
  target_id        = module.ec2_instance_worker[count.index].id
  port             = 443
}

resource "aws_iam_instance_profile" "loki_profile" {
  name = "${var.environment}-loki_profile"
  role = var.instance_role
}