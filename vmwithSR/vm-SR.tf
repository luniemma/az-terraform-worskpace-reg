# Provider configuration
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"  # Specify a version constraint
    }
  }
}

provider "azurerm" {
  features {}
}

# Define variables
variable "resource_group_name" {
  default = "templehealth-prod-rg"
}

variable "location" {
  default = "East US"
}

variable "vm_name" {
  default = "templehealth-prod-app-vm"
}

variable "backup_vault_name" {
  default = "templehealth-prod-backup-vault"
}

variable "site_recovery_vault_name" {
  default = "templehealth-prod-sr-vault"
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Recovery Services Vault
resource "azurerm_recovery_services_vault" "backup_vault" {
  name                = var.backup_vault_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  soft_delete_enabled = true
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "templehealth-prod-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Subnet
resource "azurerm_subnet" "app_subnet" {
  name                 = "templehealth-prod-app-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Public IP
resource "azurerm_public_ip" "nat_pip" {
  name                = "templehealth-prod-nat-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Network Interface
resource "azurerm_network_interface" "web_nic" {
  name                = "templehealth-prod-web-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.app_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "app_vm" {
  name                = var.vm_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1ls"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.web_nic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")  # Replace with your public key path
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

# Backup Policy
resource "azurerm_backup_policy_vm" "backup_policy" {
  name                = "templehealth-prod-backup-policy"
  resource_group_name = azurerm_resource_group.rg.name
  recovery_vault_name = azurerm_recovery_services_vault.backup_vault.name

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 30
  }
}

# Backup Protection
resource "azurerm_backup_protected_vm" "backup_protection" {
  resource_group_name = azurerm_resource_group.rg.name
  recovery_vault_name = azurerm_recovery_services_vault.backup_vault.name
  source_vm_id        = azurerm_linux_virtual_machine.app_vm.id
  backup_policy_id    = azurerm_backup_policy_vm.backup_policy.id
}

# Site Recovery Vault
resource "azurerm_recovery_services_vault" "site_recovery_vault" {
  name                = var.site_recovery_vault_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  soft_delete_enabled = true
}

# Note: Site Recovery configuration is complex and often requires manual setup.
# The following resources are placeholders and may need additional configuration.

# ... [Previous code remains the same up to the Site Recovery Replication Policy] ...

## ... [Previous code remains the same up to the Site Recovery Replication Policy] ...

# Site Recovery Replication Policy
resource "azurerm_site_recovery_replication_policy" "policy" {
  name                                                 = "templehealth-prod-sr-replication-policy"
  resource_group_name                                  = azurerm_resource_group.rg.name
  recovery_vault_name                                  = azurerm_recovery_services_vault.site_recovery_vault.name
  recovery_point_retention_in_minutes                  = 24 * 60
  application_consistent_snapshot_frequency_in_minutes = 4 * 60
}

# Primary Region Site Recovery Fabric
resource "azurerm_site_recovery_fabric" "primary_fabric" {
  name                = "primary-fabric"
  resource_group_name = azurerm_resource_group.rg.name
  recovery_vault_name = azurerm_recovery_services_vault.site_recovery_vault.name
  location            = azurerm_resource_group.rg.location
}

# Primary Region Site Recovery Protection Container
resource "azurerm_site_recovery_protection_container" "primary_container" {
  name                 = "primary-container"
  resource_group_name  = azurerm_resource_group.rg.name
  recovery_vault_name  = azurerm_recovery_services_vault.site_recovery_vault.name
  recovery_fabric_name = azurerm_site_recovery_fabric.primary_fabric.name
}

# Secondary Region Resources (for disaster recovery)
resource "azurerm_resource_group" "secondary_rg" {
  name     = "${var.resource_group_name}-secondary"
  location = "West US"  # Choose a different region for disaster recovery
}

resource "azurerm_virtual_network" "secondary_vnet" {
  name                = "templehealth-prod-secondary-vnet"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.secondary_rg.location
  resource_group_name = azurerm_resource_group.secondary_rg.name
}

resource "azurerm_subnet" "secondary_subnet" {
  name                 = "templehealth-prod-secondary-subnet"
  resource_group_name  = azurerm_resource_group.secondary_rg.name
  virtual_network_name = azurerm_virtual_network.secondary_vnet.name
  address_prefixes     = ["10.1.1.0/24"]
}

# Site Recovery Fabric for Secondary Region
resource "azurerm_site_recovery_fabric" "secondary_fabric" {
  name                = "secondary-fabric"
  resource_group_name = azurerm_resource_group.rg.name
  recovery_vault_name = azurerm_recovery_services_vault.site_recovery_vault.name
  location            = azurerm_resource_group.secondary_rg.location
}

# Site Recovery Protection Container for Secondary Region
resource "azurerm_site_recovery_protection_container" "secondary_container" {
  name                 = "secondary-container"
  resource_group_name  = azurerm_resource_group.rg.name
  recovery_vault_name  = azurerm_recovery_services_vault.site_recovery_vault.name
  recovery_fabric_name = azurerm_site_recovery_fabric.secondary_fabric.name
}

# Site Recovery Protection Container Mapping
resource "azurerm_site_recovery_protection_container_mapping" "container_mapping" {
  name                                      = "container-mapping"
  resource_group_name                       = azurerm_resource_group.rg.name
  recovery_vault_name                       = azurerm_recovery_services_vault.site_recovery_vault.name
  recovery_fabric_name                      = azurerm_site_recovery_fabric.primary_fabric.name
  recovery_source_protection_container_name = azurerm_site_recovery_protection_container.primary_container.name
  recovery_target_protection_container_id   = azurerm_site_recovery_protection_container.secondary_container.id
  recovery_replication_policy_id            = azurerm_site_recovery_replication_policy.policy.id
}

# Site Recovery Network Mapping
resource "azurerm_site_recovery_network_mapping" "network_mapping" {
  name                        = "network-mapping"
  resource_group_name         = azurerm_resource_group.rg.name
  recovery_vault_name         = azurerm_recovery_services_vault.site_recovery_vault.name
  source_recovery_fabric_name = azurerm_site_recovery_fabric.primary_fabric.name
  target_recovery_fabric_name = azurerm_site_recovery_fabric.secondary_fabric.name
  source_network_id           = azurerm_virtual_network.vnet.id
  target_network_id           = azurerm_virtual_network.secondary_vnet.id
}

resource "azurerm_site_recovery_replicated_vm" "vm_replication" {
  name                                      = "vm-replication"
  resource_group_name                       = azurerm_resource_group.rg.name
  recovery_vault_name                       = azurerm_recovery_services_vault.site_recovery_vault.name
  source_recovery_fabric_name               = azurerm_site_recovery_fabric.primary_fabric.name
  source_vm_id                              = azurerm_linux_virtual_machine.app_vm.id
  recovery_replication_policy_id            = azurerm_site_recovery_replication_policy.policy.id
  source_recovery_protection_container_name = azurerm_site_recovery_protection_container.primary_container.name

  target_resource_group_id                = azurerm_resource_group.secondary_rg.id
  target_recovery_fabric_id               = azurerm_site_recovery_fabric.secondary_fabric.id
  target_recovery_protection_container_id = azurerm_site_recovery_protection_container.secondary_container.id

  managed_disk {
    disk_id                    = azurerm_linux_virtual_machine.app_vm.os_disk[0].managed_disk_id
    staging_storage_account_id = azurerm_storage_account.staging_storage.id
    target_resource_group_id   = azurerm_resource_group.secondary_rg.id
    target_disk_type           = "Standard_LRS"
    target_replica_disk_type   = "Standard_LRS"
  }

  network_interface {
    source_network_interface_id   = azurerm_network_interface.web_nic.id
    target_subnet_name            = azurerm_subnet.secondary_subnet.name
    recovery_public_ip_address_id = azurerm_public_ip.secondary_pip.id
  }

  depends_on = [
    azurerm_site_recovery_protection_container_mapping.container_mapping,
    azurerm_site_recovery_network_mapping.network_mapping,
  ]
}
# Additional resources needed for Site Recovery setup
resource "azurerm_storage_account" "staging_storage" {
  name                     = "templesrstaging"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_public_ip" "secondary_pip" {
  name                = "templehealth-prod-secondary-pip"
  location            = azurerm_resource_group.secondary_rg.location
  resource_group_name = azurerm_resource_group.secondary_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}