

aws_region = "us-east-1"
cidr_block = "10.0.0.0/16"


public_subnets = [
  {
    cidr_block = "10.0.1.0/24"
  },
  {
    cidr_block = "10.0.2.0/24"
  }
]

private_subnets = [
  {
    cidr_block = "10.0.3.0/24"
  },
  {
    cidr_block = "10.0.4.0/24"
  }
]

name             = "gatus"
domain_name      = "tm.ayubcoderco.com"
hosted_zone_name = "ayubcoderco.com"





alb_sg = [
  {
    port        = 80
    description = "Allow HTTP from anywhere"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    port        = 443
    description = "Allow HTTPS from anywhere"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
]




container_name   = "gatus"
container_image  = "ghcr.io/twin/gatus:latest"
container_cpu    = 256
container_memory = 512
desired_count    = 1