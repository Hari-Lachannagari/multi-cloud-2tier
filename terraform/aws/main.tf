# AWS Infrastructure for Multi-Cloud E-Commerce Application
# Includes: VPC, EKS, RDS, ECR, ALB

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Create VPC
module "network" {
  source        = "./modules/network"
  aws_region    = var.aws_region
  environment   = var.environment
  vpc_cidr      = "10.0.0.0/16"
}

# Create EKS Cluster
module "kubernetes" {
  source           = "./modules/kubernetes"
  cluster_name     = var.cluster_name
  cluster_version  = var.cluster_version
  instance_type    = var.instance_type
  desired_capacity = var.desired_capacity
  min_capacity     = var.min_capacity
  max_capacity     = var.max_capacity
  subnet_ids       = module.network.public_subnet_ids
}

# Create ECR Repository
module "container_registry" {
  source         = "./modules/container-registry"
  registry_name  = var.registry_name
  scan_on_push   = true
  image_tag_mutability = "MUTABLE"
}

# RDS PostgreSQL Database
resource "aws_db_subnet_group" "main" {
  name       = "ecommerce-db-subnet-group"
  subnet_ids = module.network.private_subnet_ids

  tags = {
    Name = "ecommerce-db-subnet-group"
  }
}

resource "aws_db_instance" "postgres" {
  allocated_storage    = 20
  max_allocated_storage = 100
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "15.3"
  instance_class       = "db.t3.micro"
  db_name              = "ecommerce_db"
  username             = "ecommerce"
  password             = random_password.db_password.result
  
  db_subnet_group_name   = aws_db_subnet_group.main.name
  publicly_accessible    = false
  skip_final_snapshot    = false
  final_snapshot_identifier = "ecommerce-db-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "mon:04:00-mon:05:00"
  
  multi_az               = true
  storage_encrypted      = true

  tags = {
    Name = "ecommerce-postgres"
  }
}

# Generate random password for database
resource "random_password" "db_password" {
  length  = 16
  special = true
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "ecommerce-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = module.network.public_subnet_ids

  tags = {
    Name = "ecommerce-alb"
  }
}

# ALB Target Group
resource "aws_lb_target_group" "app" {
  name        = "ecommerce-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.network.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = "/"
    matcher             = "200"
  }

  tags = {
    Name = "ecommerce-tg"
  }
}

# ALB Listener
resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# Security Group for ALB
resource "aws_security_group" "alb" {
  name        = "ecommerce-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = module.network.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecommerce-alb-sg"
  }
}
