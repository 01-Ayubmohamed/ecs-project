
output "cluster_arn" {
  value       = aws_ecs_cluster.gatus_cluster.arn
  description = "ARN of the ECS cluster"
}

output "service_arn" {
  value       = aws_ecs_service.gatus_service.arn
  description = "ARN of the ECS service"
}
