# AWS infrastructure for the first deployment phase.
# Includes only VPC, EKS, and ECR; the application does not require a database.

# Create VPC
module "network" {
  source      = "../modules/network"
  aws_region  = var.aws_region
  environment = var.environment
  vpc_cidr    = var.vpc_cidr
}

# Create EKS Cluster
module "kubernetes" {
  source           = "../modules/kubernetes"
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
  source               = "../modules/container-registry"
  registry_name        = var.registry_name
  scan_on_push         = true
  image_tag_mutability = "MUTABLE"
}
