variable "name" {
    type = string
    default = "gatus"
    
}

variable "domain_name" {
    type       = string
    description = "Domain ACM certificate will cover"
}

variable "hosted_zone_name" {
    type       = string
    description = "Root domain for Route 53 hosted zone"
}