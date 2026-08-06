

resource "aws_cloudwatch_log_group" "gatus_cloudwatch" {
  name              = "${var.name}-cloudwatch"
  retention_in_days = 7
}

resource "aws_ecs_cluster" "gatus_cluster" {
  name = "${var.name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

data "aws_region" "current" {}


resource "aws_ecs_cluster_capacity_providers" "gatus_cp" {
  cluster_name = aws_ecs_cluster.gatus_cluster.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  
    default_capacity_provider_strategy {
        base              = 1
        weight            = 20
        capacity_provider = "FARGATE"
}

    default_capacity_provider_strategy {
        base              = 0
        weight            = 80
        capacity_provider = "FARGATE_SPOT"
}
}



resource "aws_security_group" "ecs_sg" {
    name        = "${var.name}-ecs-sg"
    vpc_id      =  var.vpc_id

  ingress {
    from_port       = var.container_port 
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [var.alb_sg]
  }

  egress {
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block]
  }
}

resource "aws_ecs_task_definition" "gatus_task" {
  family                   = "${var.name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = tostring(var.container_cpu)
  memory                   = tostring(var.container_memory)
  execution_role_arn       = var.ecs_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.container_image
      cpu       = var.container_cpu
      memory    = var.container_memory
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ],

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.gatus_cloudwatch.name
          awslogs-region        = data.aws_region.current.region
          awslogs-stream-prefix = var.name
        }
      }
    }
  ])
}

resource "aws_ecs_service" "gatus_service" {
  name            = "${var.name}-service"
  cluster         = aws_ecs_cluster.gatus_cluster.id
  task_definition = aws_ecs_task_definition.gatus_task.arn
  desired_count   = var.desired_count
  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 20
    base              = 1
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 80
    base              = 0

  }

  lifecycle {
    ignore_changes = [task_definition, desired_count,]
  }

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }
}

