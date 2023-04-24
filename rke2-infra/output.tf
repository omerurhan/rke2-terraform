output "cp_public_ip" {
  description = "The public IP address assigned to the instance, if applicable. NOTE: If you are using an aws_eip with your instance, you should refer to the EIP's address directly and not use `public_ip` as this field will change after the EIP is attached"
  value       = [ for host in module.ec2_instance_cp : host.public_ip ]
}

output "worker_public_ip" {
  description = "The public IP address assigned to the instance, if applicable. NOTE: If you are using an aws_eip with your instance, you should refer to the EIP's address directly and not use `public_ip` as this field will change after the EIP is attached"
  value       = [ for host in module.ec2_instance_worker : host.public_ip ]
}

output "lb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = module.nlb_cp.lb_dns_name
}
