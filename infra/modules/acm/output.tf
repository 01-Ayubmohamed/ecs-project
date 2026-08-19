

output "certificate_arn" {
  value       = aws_acm_certificate_validation.main.certificate_arn
  description = "ARN of the ACM certificate"
}
