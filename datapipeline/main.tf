terraform { 
  cloud { 
    
    organization = "Terraform-Demo-emma" 

    workspaces { 
      name = "az-terraform-worskpace-reg" 
    } 
  } 
 


  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  subscription_id = "606e824b-aaf7-4b4e-9057-b459f6a4436d"
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

module "data_factory" {
  source              = "./modules/data_factory"
  name                = var.data_factory_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

module "databricks" {
  source              = "./modules/databricks"
  name                = var.databricks_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}