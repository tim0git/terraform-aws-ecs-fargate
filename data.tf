data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_ecs_cluster" "this" {
  cluster_name = var.cluster_name
}

data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_security_groups" "this" {
  filter {
    name   = "tag:Name"
    values = var.security_groups_names
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "tag:Name"
    values = var.subnet_names
  }
}

data "aws_lb" "this" {
  name = var.load_balancer_name
}

data "aws_lb_listener" "this" {
  load_balancer_arn = data.aws_lb.this.arn
  port              = var.load_balancer_listener_port
}
