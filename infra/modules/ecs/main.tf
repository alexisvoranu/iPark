resource "aws_ecr_repository" "ipark_app_repo" {
  name                 = "ipark-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.environment}-ipark-apps"
  retention_in_days = 7
}

resource "aws_ecs_cluster" "ipark_cluster" {
  name = "${var.environment}-ipark-cluster"
}

resource "aws_ecs_task_definition" "ipark_task" {
  family                   = "${var.environment}-ipark-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.execution_role_arn

  container_definitions = jsonencode([
    {
      name         = "ipark-container"
      image        = "${aws_ecr_repository.ipark_app_repo.repository_url}:latest"
      essential    = true
      portMappings = [
        {
          containerPort = var.port
          hostPort      = var.port
        }
      ]
      environment = [
        { name = "PORT", value = tostring(var.port) },
        { name = "URL", value = "http://${var.alb_dns_name}" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options   = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "ipark_service" {
  name                              = "${var.environment}-ipark-service"
  cluster                           = aws_ecs_cluster.ipark_cluster.id
  task_definition                   = aws_ecs_task_definition.ipark_task.arn
  desired_count                     = 1
  launch_type                       = "FARGATE"
  health_check_grace_period_seconds = 180

  network_configuration {
    subnets          = [var.subnet_id]
    security_groups  = [var.security_group_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "ipark-container"
    container_port   = var.port
  }

  depends_on = [var.alb_listener_arn]
}