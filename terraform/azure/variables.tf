variable "azure_region" {
  description = "Azure region for all resources."
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Resource group name."
  type        = string
  default     = "ecommerce-rg"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "production"
}

variable "cluster_name" {
  description = "AKS cluster name."
  type        = string
  default     = "ecommerce-aks"
}

variable "kubernetes_version" {
  description = "AKS Kubernetes version."
  type        = string
  default     = null
}

variable "node_count" {
  description = "Initial AKS node count."
  type        = number
  default     = 2
}

variable "node_vm_size" {
  description = "AKS node VM size."
  type        = string
  default     = "Standard_D2s_v5"
}

