# Azure Infrastructure for Multi-Cloud E-Commerce Application
# Includes: AKS, ACR, PostgreSQL, Application Gateway

# Data source for current Azure context
data "azurerm_client_config" "current" {}

# Create Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.azure_region

  tags = {
    Environment = var.environment
    Project     = "ecommerce"
  }
}

# Create Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "ecommerce-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    Name = "ecommerce-vnet"
  }
}

# Create Subnets
resource "azurerm_subnet" "aks" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "db" {
  name                 = "db-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]

  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

# Create AKS Cluster
resource "azurerm_kubernetes_cluster" "main" {
  name                = var.cluster_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  kubernetes_version  = var.kubernetes_version
  dns_prefix          = var.cluster_name

  default_node_pool {
    name           = "default"
    node_count     = var.node_count
    vm_size        = var.node_vm_size
    vnet_subnet_id = azurerm_subnet.aks.id

    auto_scaling_enabled = true
    min_count            = 2
    max_count            = 10
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    service_cidr   = "10.1.0.0/16"
    dns_service_ip = "10.1.0.10"
  }

  tags = {
    Environment = var.environment
  }
}

# Create Azure Container Registry
resource "azurerm_container_registry" "main" {
  name                = "ecommerce${lower(replace(azurerm_resource_group.main.name, "-", ""))}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  admin_enabled       = false
  sku                 = "Standard"

  tags = {
    Environment = var.environment
  }
}

# Attach ACR to AKS
resource "azurerm_role_assignment" "aks_acr" {
  scope              = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id       = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}

# Create PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "main" {
  name                   = "ecommerce-db"
  location               = azurerm_resource_group.main.location
  resource_group_name    = azurerm_resource_group.main.name
  version                = "15"
  delegated_subnet_id    = azurerm_subnet.db.id
  administrator_login    = "ecommerce"
  administrator_password = random_password.db_password.result

  backup_retention_days  = 7
  geo_redundant_backup_enabled = true
  zone                   = 1

  tags = {
    Environment = var.environment
  }
}

# PostgreSQL Flexible Server Configuration
resource "azurerm_postgresql_flexible_server_configuration" "main" {
  name       = "require_secure_transfer"
  server_id  = azurerm_postgresql_flexible_server.main.id
  value      = "on"
}

# Create Database
resource "azurerm_postgresql_flexible_server_database" "ecommerce" {
  name       = "ecommerce_db"
  server_id  = azurerm_postgresql_flexible_server.main.id
  charset    = "UTF8"
  collation  = "en_US.utf8"
}

# Generate random password for database
resource "random_password" "db_password" {
  length  = 16
  special = true
}

# Create Application Gateway
resource "azurerm_public_ip" "appgw" {
  name                = "appgw-pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "main" {
  name                = "ecommerce-appgw"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name          = "gateway-ip-config"
    subnet_id     = azurerm_subnet.aks.id
  }

  frontend_port {
    name = "http"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "frontend-ip-config"
    public_ip_address_id = azurerm_public_ip.appgw.id
  }

  backend_address_pool {
    name = "backend-pool"
  }

  backend_http_settings {
    name                  = "backend-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "frontend-ip-config"
    frontend_port_name             = "http"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "backend-pool"
    backend_http_settings_name = "backend-http-settings"
    priority                   = 100
  }

  tags = {
    Environment = var.environment
  }
}
