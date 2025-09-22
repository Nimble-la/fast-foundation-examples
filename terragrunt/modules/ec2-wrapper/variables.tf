variable "name" {
  description = "Name of the EC2 instance and associated resources"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC to deploy into"
  type        = string
}

variable "vpc_private_subnets" {
  description = "Private subnets within the VPC for securely deploying the EC2 instance"
  type        = list(string)
  validation {
    condition     = length(var.vpc_private_subnets) > 0
    error_message = "At least one private subnet must be provided."
  }
}

variable "vpc_public_subnets" {
  description = "Public subnets within the VPC for ALB"
  type        = list(string)
  validation {
    condition     = length(var.vpc_public_subnets) > 0
    error_message = "At least one public subnet must be provided."
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "EC2 Key Pair name"
  type        = string
  default     = null
}

variable "app_port" {
  description = "Port where the application runs"
  type        = number
  default     = 8080
}

variable "health_check_path" {
  description = "Path for ALB health checks"
  type        = string
  default     = "/health"
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection on ALB"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}