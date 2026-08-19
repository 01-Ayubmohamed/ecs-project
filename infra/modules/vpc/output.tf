output "vpc_id" {
  description = "VPC ID, created by the VPC module"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "list of public subnets IDs"
  value       = [for subnet in aws_subnet.public_subnet : subnet.id]
}

output "private_subnet_ids" {
  description = "list of private subnets IDs"
  value       = [for subnet in aws_subnet.private_subnet : subnet.id]
}