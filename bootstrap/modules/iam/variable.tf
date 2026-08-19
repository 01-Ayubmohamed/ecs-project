variable "name" {
  description = "Prefix used to name every resource created"
  type        = string
}

variable "bucket_name" {
  description = "Name of the Terraform state bucket. Only the terraform role gets access to it"
  type        = string
}

variable "allowed_subjects" {
  description = <<-EOT
    List of GitHub OIDC subject claims allowed to assume either role.
    Format: repo:<org>/<repo>:ref:refs/heads/<branch>
            repo:<org>/<repo>:pull_request

    Examples:
      - "repo:01-Ayubmohamed/ecs-project:ref:refs/heads/main"  -> only main branch
      - "repo:01-Ayubmohamed/ecs-project:pull_request"         -> PR-triggered workflows
  EOT
  type        = list(string)
  default     = []
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository the deploy role is allowed to push/pull"
  type        = string
}

variable "ecs_task_role_name" {
  description = "Predicted name of the ECS task role infra/modules/iam will create. Must exactly match the `name` used there"
  type        = string
}

variable "ecs_task_execution_role_name" {
  description = "Predicted name of the ECS task execution role infra/modules/iam will create. Must exactly match the `name` used there"
  type        = string
}
