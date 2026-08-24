output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.main.name
}

output "aks_cluster_endpoint" {
  value     = azurerm_kubernetes_cluster.main.kube_config[0].host
  sensitive = true
}

output "acr_login_server" {
  value = azurerm_container_registry.main.login_server
}

output "app_gateway_public_ip" {
  value = azurerm_public_ip.appgw.ip_address
}
