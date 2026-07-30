
module "ecr" {
  source = "./modules/ecr"
  name   = var.name

}

module "iam" {
  source                       = "./modules/iam"
  name                         = var.name
  bucket_name                  = var.bucket_name
  allowed_subjects             = var.allowed_subjects
  ecr_repository_name          = module.ecr.ecr_repository_name
  ecs_task_role_name           = var.ecs_task_role_name
  ecs_task_execution_role_name = var.ecs_task_execution_role_name
}

module "s3" {
  source      = "./modules/s3"
  bucket_name = var.bucket_name

}