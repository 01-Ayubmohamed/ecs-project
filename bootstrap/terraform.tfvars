aws_region  = "us-east-1"
name        = "gatus"
bucket_name = "terraform-gatus-state"

allowed_subjects = [
  "repo:01-Ayubmohamed/ecs-project:ref:refs/heads/main"
]

ecs_task_role_name           = "gatus-ecs-task-role"
ecs_task_execution_role_name = "gatus-ecsTaskExecutionRole"
