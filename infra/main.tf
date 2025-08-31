resource "aws_ecs_cluster" "this" {
  name = format("%s-cluster", var.cluster_name)

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_lb" "this" {
  name               = format("%s-nlb", var.cluster_name)
  subnets            = var.subnets_id
  security_groups    = [aws_security_group.allow_inbound.id]
  load_balancer_type = "network"

  tags = {
    Name = format("%s-nlb", var.cluster_name)
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_lb_target_group" "this" {
  name        = format("%s-tg", var.cluster_name)
  port        = 80
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  tags = {
    Name = format("%s-tg", var.cluster_name)
  }
}

resource "aws_security_group" "allow_inbound" {
  name        = format("%s-sg", var.cluster_name)
  vpc_id      = var.vpc_id
  description = "Allow inbound traffic"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = format("%s-sg", var.cluster_name)
  }
}

resource "aws_vpc_security_group_ingress_rule" "web" {
  security_group_id = aws_security_group.allow_inbound.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
  description       = "Acesso Web"
}

resource "aws_vpc_security_group_ingress_rule" "container" {
  security_group_id = aws_security_group.allow_inbound.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8000
  ip_protocol       = "tcp"
  to_port           = 8000
  description       = "Acesso Web"
}

output "load_balancer_arn" {
  value = aws_lb_target_group.this.arn
}

output "nlb_dns_name" {
  value = format("http://%s", aws_lb.this.dns_name)
}