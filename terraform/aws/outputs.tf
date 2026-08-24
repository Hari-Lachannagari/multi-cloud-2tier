output "eks_cluster_name" {
  value = module.kubernetes.cluster_name
}

output "eks_cluster_endpoint" {
  value     = module.kubernetes.cluster_endpoint
  sensitive = true
}

output "ecr_repository_url" {
  value = module.backend_registry.repository_url
}

output "frontend_ecr_repository_url" {
  value = module.frontend_registry.repository_url
}
