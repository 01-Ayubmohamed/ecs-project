
variable "vpc_id" {
  description = "VPC ID for the ALB"
  type        = string
}

variable "cidr_block" {
  type        = string
  description = "cidr block for VPC"
}


variable "name" {
  type = string
  default = "gatus"
}

variable "subnet_ids" {
  type = list(string)
  description = "list of subnet IDs for the ALB"
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

variable "certificate_arn" {
  description = "ARN of the SSL certificate for the ALB"
  type        = string
  default     = ""
}

variable "domain_name" {
    type       = string
    description = "Domain ACM certificate will cover"
}

variable "hosted_zone_name" {
    type       = string
    description = "Root domain for Route 53 hosted zone"
}