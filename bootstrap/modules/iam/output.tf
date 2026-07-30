output "build_role_arn" {
  value      = aws_iam_role.build.arn
  description = "ARN for build.yml assumes to build, scan, and push the Docker image"
}

output "deploy_role_arn" {
  value       = aws_iam_role.deploy.arn
  description = "ARN docker.yml assumes to build, push, and deploy"
}

output "terraform_role_arn" {
  value       = aws_iam_role.terraform.arn
  description = "ARN terraform.yml assumes to plan/apply infra/"
}

output "oidc_provider_arn" {
  value       = aws_iam_openid_connect_provider.github.arn
  description = "ARN of the shared GitHub OIDC provider - only one should exist per AWS account"
}
