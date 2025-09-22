# Core EC2 module outputs
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = module.ec2_instance.id
}

output "private_ip" {
  description = "Private IP address of the instance"
  value       = module.ec2_instance.private_ip
}

output "availability_zone" {
  description = "Availability zone of the instance"
  value       = module.ec2_instance.availability_zone
}

# ALB module outputs
output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = module.alb.dns_name
}

output "load_balancer_arn" {
  description = "ARN of the load balancer"
  value       = module.alb.arn
}

output "target_groups" {
  description = "Target groups created by ALB module"
  value       = module.alb.target_groups
}

output "web_security_group_id" {
  description = "ID of the web security group"
  value       = module.ec2_instance.security_group_id
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = module.alb.security_group_id
}