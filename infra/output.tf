

output "alb_dns_name" {
  description = "DNS name of the ALB — use this to access the app or configure Route53"
  value       = module.ALB.alb_dns_name
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = module.ECS.cluster_arn
}

output "ecs_service_arn" {
  description = "ARN of the ECS service"
  value       = module.ECS.service_arn
}
