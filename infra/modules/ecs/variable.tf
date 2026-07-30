variable "vpc_id" {
    description = "VPC ID where the ECS cluster will be deployed"
    type        = string
}

variable "subnet_ids" {
    description = "List of subnet IDs for the ECS cluster"
    type        = list(string)
}

variable "alb_sg" {
    description = "Security group ID for the Application Load Balancer"
    type        = string
}

variable "target_group_arn" {
    description = "ARN of the target group for the ECS service"
    type        = string
}

variable "ecs_execution_role_arn" {
    description = "ARN of the ECS execution role"
    type        = string
}

variable "ecs_task_role_arn" {
    description = "ARN of the ECS task role"
    type        = string
}

variable "name" {
    description = "Name of the ECS cluster and related resources"
    type    =  string 
}

variable "container_name" {
    description = "Name of the container"
    type        = string
}

variable "container_image" {
    description = "Docker image for the container"
    type        = string
}

variable "container_cpu" {
    description = "CPU units for the container"
    type        = number
}

variable "container_memory" {
    description = "Memory for the container"
    type        = number
}


variable "desired_count" {
    description = "Desired number of ECS tasks"
    type        = number
    default     = 1
}

variable "container_port" {
    description = "Port on which the container listens"
    type        = number
    default     = 8080
}

