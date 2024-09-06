# main.tf
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

module "network" {
  source              = "./modules/network"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  vnet_name           = var.vnet_name
  vnet_address_space  = var.vnet_address_space
  subnet_name         = var.subnet_name
  subnet_prefixes     = var.subnet_prefixes
}

module "windows_vm" {
  source              = "./modules/vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  vm_name             = "${var.vm_name_prefix}-win"
  subnet_id           = module.network.subnet_id
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  os_type             = "windows"
}

module "ubuntu_vms" {
  source              = "./modules/vm"
  count               = 2
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  vm_name             = "${var.vm_name_prefix}-ubuntu-${count.index + 1}"
  subnet_id           = module.network.subnet_id
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  os_type             = "ubuntu"
}

module "rhel_vm" {
  source              = "./modules/vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  vm_name             = "${var.vm_name_prefix}-rhel"
  subnet_id           = module.network.subnet_id
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  os_type             = "rhel"
}