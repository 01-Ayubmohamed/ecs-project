terraform {
  required_version = "~> 1.15"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }



  backend "s3" {
    bucket       = "terraform-gatus-state"
    key          = "ecs-project/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}


provider "aws" {
  region = var.aws_region
}
