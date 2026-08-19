variable "cidr_block" {
  type        = string
  description = "cidr block for VPC"
  default     = "10.0.0.0/16"
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
  description = "Prefix used to name every resource created"
  type        = string
}