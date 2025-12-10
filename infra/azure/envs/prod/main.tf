terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.108"
    }
  }
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

locals {
  name_suffix = "prod"
  tags = {
    env = "prod"
    app = "healthcare"
  }
}

module "rg" {
  source   = "../../modules/resource_group"
  name     = "hc-${local.name_suffix}-rg"
  location = var.location
  tags     = local.tags
}

module "network" {
  source              = "../../modules/network"
  vnet_name           = "hc-${local.name_suffix}-vnet"
  address_space       = ["10.50.0.0/16"]
  location            = var.location
  resource_group_name = module.rg.name
  subnet_name         = "aks-subnet"
  subnet_prefixes     = ["10.50.1.0/24"]
  tags                = local.tags
}

module "law" {
  source              = "../../modules/log_analytics"
  name                = "hc-${local.name_suffix}-law"
  location            = var.location
  resource_group_name = module.rg.name
  tags                = local.tags
}

module "acr" {
  source              = "../../modules/acr"
  name                = "hc${local.name_suffix}acr"
  location            = var.location
  resource_group_name = module.rg.name
  sku                 = "Basic"
  tags                = local.tags
}

module "kv" {
  source              = "../../modules/keyvault"
  name                = "hc-${local.name_suffix}-kv"
  location            = var.location
  resource_group_name = module.rg.name
  tenant_id           = var.tenant_id
  tags                = local.tags
}

module "aks" {
  source                     = "../../modules/aks"
  name                       = "hc-${local.name_suffix}-aks"
  location                   = var.location
  resource_group_name        = module.rg.name
  dns_prefix                 = "hc-${local.name_suffix}"
  vm_size                    = var.vm_size
  node_count                 = var.node_count
  subnet_id                  = module.network.subnet_id
  service_cidr               = "10.60.0.0/16"
  dns_service_ip             = "10.60.0.10"
  docker_bridge_cidr         = "172.17.0.1/16"
  log_analytics_workspace_id = module.law.id
  acr_id                     = "/subscriptions/${var.subscription_id}/resourceGroups/${module.rg.name}/providers/Microsoft.ContainerRegistry/registries/${module.acr.name}"
  tags                       = local.tags
}
