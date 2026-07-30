output "ecr_repository_url" {
  value       = aws_ecr_repository.main.repository_url
  description = "URL of the ECR repository"
}

output "ecr_repository_name" {
  value       = aws_ecr_repository.main.name
  description = "Name of the ECR repository"
}

output "ecr_repository_arn" {
  value       = aws_ecr_repository.main.arn
  description = "ARN of the ECR repository"
}