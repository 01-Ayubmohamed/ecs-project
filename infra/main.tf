module "VPC" {
  source          = "./modules/vpc"
  cidr_block      = var.cidr_block
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  name            = var.name
}


module "ALB" {
  source           = "./modules/alb"
  vpc_id           = module.VPC.vpc_id
  subnet_ids       = module.VPC.public_subnet_ids
  cidr_block       = var.cidr_block
  name             = var.name
  alb_sg           = var.alb_sg
  certificate_arn  = module.ACM.certificate_arn
  domain_name      = var.domain_name
  hosted_zone_name = var.hosted_zone_name


}

module "ACM" {
  source           = "./modules/acm"
  name             = var.name
  domain_name      = var.domain_name
  hosted_zone_name = var.hosted_zone_name
}


module "ECS" {
  source                 = "./modules/ecs"
  vpc_id                 = module.VPC.vpc_id
  subnet_ids             = module.VPC.private_subnet_ids
  name                   = var.name
  alb_sg                 = module.ALB.alb_sg_id
  target_group_arn       = module.ALB.target_group_arn
  ecs_execution_role_arn = module.IAM.ecs_execution_role_arn
  ecs_task_role_arn      = module.IAM.ecs_task_role_arn
  container_name         = var.container_name
  container_image        = var.container_image
  container_cpu          = var.container_cpu
  container_memory       = var.container_memory
  container_port         = var.container_port
  desired_count          = var.desired_count
}

module "IAM" {
  source = "./modules/iam"
  name   = var.name

}


