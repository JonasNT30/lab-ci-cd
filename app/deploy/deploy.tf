# data.tf
data "aws_security_groups" "this" {
  filter {
    name   = "group-name"
    values = [var.security_group_name]
  }
}

data "aws_lb" "this" {
  name = var.nlb_name
}

data "aws_lb_target_group" "this" {
  name = var.tg_name
}


# deploy.tf
resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.container_name}"
  retention_in_days = 7
}

resource "aws_ecs_service" "this" {
  name            = var.ecs_service_name
  cluster         = var.ecs_cluster_name
  task_definition = var.task_definition_name
  desired_count   = 3
  launch_type     = "FARGATE"

  network_configuration {
    subnets = [
      "subnet-013d682169102afe0",
      "subnet-076059ee3f9904a0d",
      "subnet-07ed8aa5282321a33"
    ]
    assign_public_ip = true
    security_groups  = [data.aws_security_groups.this.ids[0]]
  }

  load_balancer {
    container_name   = var.container_name
    container_port   = 8000
    target_group_arn = data.aws_lb_target_group.this.arn
  }

  depends_on = [aws_cloudwatch_log_group.this]
}


# variables.tf
variable "container_name" {
  type    = string
  default = "ci-cd-app"
}

variable "ecs_service_name" {
  type = string
}

variable "ecs_cluster_name" {
  type = string
}

variable "task_definition_name" {
  type = string
}

variable "security_group_name" {
  type    = string
  default = "sg-0e90f81d503fe74a9"
}

variable "nlb_name" {
  type    = string
  default = "app-prod-nlb"
}

variable "tg_name" {
  type    = string
  default = "app-prod-tg"
}

output "nlb_dns_name" {
  value = data.aws_lb.this.dns_name
}