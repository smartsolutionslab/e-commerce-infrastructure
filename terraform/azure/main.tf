terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "ecommerce" {
  name     = "rg-ecommerce-${var.environment}"
  location = var.location

  tags = {
    Environment = var.environment
    Project     = "ecommerce-platform"
  }
}

# Container Registry
resource "azurerm_container_registry" "ecommerce" {
  name                = "acecommerce${var.environment}"
  resource_group_name = azurerm_resource_group.ecommerce.name
  location           = azurerm_resource_group.ecommerce.location
  sku                = "Premium"
  admin_enabled      = true

  tags = {
    Environment = var.environment
  }
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "ecommerce" {
  name                = "aks-ecommerce-${var.environment}"
  location           = azurerm_resource_group.ecommerce.location
  resource_group_name = azurerm_resource_group.ecommerce.name
  dns_prefix         = "aks-ecommerce-${var.environment}"

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.vm_size
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = var.environment
  }
}

# SQL Server
resource "azurerm_mssql_server" "ecommerce" {
  name                         = "sql-ecommerce-${var.environment}"
  resource_group_name          = azurerm_resource_group.ecommerce.name
  location                    = azurerm_resource_group.ecommerce.location
  version                     = "12.0"
  administrator_login         = var.sql_admin_username
  administrator_login_password = var.sql_admin_password

  tags = {
    Environment = var.environment
  }
}

# Databases
resource "azurerm_mssql_database" "customer_db" {
  name      = "ecommerce-customer-${var.environment}"
  server_id = azurerm_mssql_server.ecommerce.id
  sku_name  = var.database_sku
}

resource "azurerm_mssql_database" "product_db" {
  name      = "ecommerce-product-${var.environment}"
  server_id = azurerm_mssql_server.ecommerce.id
  sku_name  = var.database_sku
}

resource "azurerm_mssql_database" "order_db" {
  name      = "ecommerce-order-${var.environment}"
  server_id = azurerm_mssql_server.ecommerce.id
  sku_name  = var.database_sku
}

# Redis Cache
resource "azurerm_redis_cache" "ecommerce" {
  name                = "redis-ecommerce-${var.environment}"
  location           = azurerm_resource_group.ecommerce.location
  resource_group_name = azurerm_resource_group.ecommerce.name
  capacity           = 1
  family             = "C"
  sku_name           = "Standard"
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"

  tags = {
    Environment = var.environment
  }
}

# Service Bus (for RabbitMQ alternative)
resource "azurerm_servicebus_namespace" "ecommerce" {
  name                = "sb-ecommerce-${var.environment}"
  location           = azurerm_resource_group.ecommerce.location
  resource_group_name = azurerm_resource_group.ecommerce.name
  sku                = "Standard"

  tags = {
    Environment = var.environment
  }
}
