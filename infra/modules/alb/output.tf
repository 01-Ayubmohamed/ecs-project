

output "alb_arn" {
    description = "ARN of the ALB, created by the ALB module"
    value       = aws_lb.main.arn
}

output "alb_dns_name" {
    description = "DNS name of the ALB, created by the ALB module"
    value       = aws_lb.main.dns_name
}


output "target_group_arn" {
    description = "ARN of the target group, created by the ALB module"
    value       = aws_lb_target_group.lb_target_group.arn
}

output "alb_sg_id" {
  description = "Security group ID of the ALB"
  value       = aws_security_group.alb_sg.id
}
