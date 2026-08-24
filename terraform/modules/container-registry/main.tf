# Container Registry Module for AWS ECR

variable "registry_name" {
  type = string
}

variable "image_tag_mutability" {
  type    = string
  default = "MUTABLE"
}

variable "scan_on_push" {
  type    = bool
  default = true
}

resource "aws_ecr_repository" "ecommerce" {
  name                 = var.registry_name
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  tags = {
    Name = "ecommerce-registry"
  }
}

resource "aws_ecr_lifecycle_policy" "ecommerce" {
  repository = aws_ecr_repository.ecommerce.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus       = "any"
          countType       = "imageCountMoreThan"
          countNumber     = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

output "repository_url" {
  value = aws_ecr_repository.ecommerce.repository_url
}

output "repository_arn" {
  value = aws_ecr_repository.ecommerce.arn
}
