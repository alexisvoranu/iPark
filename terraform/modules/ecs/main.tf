resource "aws_ecr_repository" "ipark_app_repo" {
  name                 = "ipark-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecs_cluster" "ipark_cluster" {
  name = "${var.environment}-ipark-cluster"
}

resource "aws_lb" "ipark_alb" {
  name               = "${var.environment}-ipark-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.server_sg_id]
  subnets            = [var.public_subnet_id, var.public_subnet_b_id]
}

resource "aws_lb_target_group" "ipark_tg" {
  name        = "${var.environment}-ipark-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/iPark/health"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "ipark_listener" {
  load_balancer_arn = aws_lb.ipark_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ipark_tg.arn
  }
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.environment}-ipark-apps"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "ipark_task" {
  family                   = "${var.environment}-ipark-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.ecs_execution_role_arn

  container_definitions = jsonencode([
    {
      name         = "ipark-container"
      image        = "${aws_ecr_repository.ipark_app_repo.repository_url}:latest"
      essential    = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
      environment = [
        { name = "PORT", value = tostring(var.port) },
        { name = "URL", value = "http://${aws_lb.ipark_alb.dns_name}" }
      ]
      secrets = [
        {
          name      = "STRIPE_API_KEY"
          valueFrom = "${var.app_secrets_arn}:STRIPE_API_KEY::"
        },
        {
          name      = "STRIPE_API_PUBLIC_KEY"
          valueFrom = "${var.app_secrets_arn}:STRIPE_API_PUBLIC_KEY::"
        },
        {
          name      = "STRIPE_WEBHOOK_SECRET"
          valueFrom = "${var.app_secrets_arn}:STRIPE_WEBHOOK_SECRET::"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options   = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name
          "awslogs-region"        = "eu-central-1"
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
    subnets          = [var.public_subnet_id]
    security_groups  = [var.server_sg_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ipark_tg.arn
    container_name   = "ipark-container"
    container_port   = 8080
  }

  depends_on = [aws_lb_listener.ipark_listener]
}