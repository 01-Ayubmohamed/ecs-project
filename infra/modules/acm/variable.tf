variable "name" {
  description = "Prefix used to name every resource created"
  type        = string
}

variable "domain_name" {
  description = "Domain ACM certificate will cover"
  type        = string

}

variable "hosted_zone_name" {
  description = "Root domain for Route 53 hosted zone"
  type        = string

}

