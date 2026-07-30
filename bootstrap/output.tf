output "ecr_repository_name" {
  value       = module.ecr.ecr_repository_name
  description = "The name of the ECR repository created"
}

output "ecr_repository_url" {
  value       = module.ecr.ecr_repository_url
  description = "The URL of the ECR repository created"
}

output "build_role_arn" {
  value       = module.iam.build_role_arn
  description = "ARN for build.yml to assume"
}

output "deploy_role_arn" {
  value       = module.iam.deploy_role_arn
  description = "ARN for docker.yml to assume"
}

output "terraform_role_arn" {
  value       = module.iam.terraform_role_arn
  description = "ARN for terraform.yml to assume"
}

output "bucket_name" {
  value       = module.s3.bucket_name
  description = "The name of the S3 bucket created for Terraform state"
}
output "bucket_arn" {
  value       = module.s3.bucket_arn
  description = "The ARN of the S3 bucket created for Terraform state"
}
