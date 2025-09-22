#============================================================================
# CORE EC2 MODULE - The base functionality with built-in security group and IAM
#============================================================================
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.8.0"

  name = var.name

  instance_type = var.instance_type
  key_name      = var.key_name
  monitoring    = true
  subnet_id     = var.vpc_private_subnets[0]
  
  vpc_security_group_ids = [module.ec2_instance_security_group.security_group_id]

  # Built-in IAM role creation  
  create_iam_instance_profile = true
  iam_role_name               = "${var.name}-role"
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  # User data for application setup
  user_data_base64 = base64encode(templatefile("${path.module}/user_data.sh", {
    app_name = var.name
  }))

  tags = var.tags
}

module "ec2_instance_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.2"

  name        = var.name
  description = "Security group usage with EC2 instance"
  vpc_id      = var.vpc_id
  
  ingress_with_source_security_group_id = [
    {
      from_port                = var.app_port
      to_port                  = var.app_port
      protocol                 = "tcp"
      description              = "Application port from ALB"
      source_security_group_id = module.alb.security_group_id
    }
  ]

  tags = var.tags
}

#============================================================================
# EXTENDED RESOURCES - Additional capabilities not in the base module
#============================================================================

# Application Load Balancer using official module
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.13.0"

  name                       = "${var.name}-alb"
  vpc_id                     = var.vpc_id
  subnets                    = var.vpc_public_subnets
  enable_deletion_protection = var.enable_deletion_protection

  # Security group rules for ALB
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"

      forward = {
        target_group_key = "ec2_instances"
      }
    }
  }

  target_groups = {
    ec2_instances = {
      name        = "${var.name}-tg"
      protocol    = "HTTP"
      port        = var.app_port
      target_type = "instance"
      target_id   = module.ec2_instance.id
      
      health_check = {
        enabled             = true
        healthy_threshold   = 2
        unhealthy_threshold = 3
        timeout             = 6
        interval            = 30
        path                = var.health_check_path
        matcher             = "200"
        port                = var.app_port
        protocol            = "HTTP"
      }
    }
  }

  tags = var.tags
}
