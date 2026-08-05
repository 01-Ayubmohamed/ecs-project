variable "aws_region" {
  type        = string
  description = "AWS region for the resources"
}

variable "cidr_block" {
  type        = string
  description = "cidr block for VPC"
}

variable "public_subnets" {
  type = list(object({
    cidr_block = string
  }))
}


variable "private_subnets" {
  type = list(object({
    cidr_block = string
  }))
}

variable "name" {
  type    = string
  default = "gatus"
}



variable "alb_sg" {
  description = "List of security group rules for ALB"
  type = list(object({
    description = string
    port        = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "domain_name" {
  description = "Domain name for the ACM certificate"
  type        = string
}

variable "hosted_zone_name" {
  description = "Hosted zone name for the ACM certificate"
  type        = string
}

variable "container_name" {
  description = "Name of the container"
  type        = string
}

variable "container_image" {
  description = "Docker image for the container"
  type        = string
}

variable "container_cpu" {
  description = "CPU units for the container"
  type        = number
}

variable "container_memory" {
  description = "Memory for the container"
  type        = number
}


variable "desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 1
}

variable "container_port" {
  description = "Port on which the container listens"
  type        = number
}