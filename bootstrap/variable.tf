variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}


variable "name" {
  description = "Prefix used to name every resource created"
  type        = string
  default     = "gatus"
}

variable "bucket_name" {
  description = "Terraform state bucket name"
  type        = string
}

variable "allowed_subjects" {
  description = "List of GitHub OIDC subject claims allowed to assume either role."
  type        = list(string)
  default     = []
}

variable "ecs_task_role_name" {
  description = "name of the ECS task role infra/modules/iam will create later"
  type        = string
}

variable "ecs_task_execution_role_name" {
  description = "name of the ECS task execution role infra/modules/iam will create later"
  type        = string
}
