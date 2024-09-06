resource "azurerm_data_factory" "data_factory" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
}

variable "name" {
  description = "Name of the Azure Data Factory"
  type        = string
}

variable "location" {
  description = "Azure region to deploy the Data Factory"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

output "data_factory_id" {
  description = "The ID of the Azure Data Factory"
  value       = azurerm_data_factory.data_factory.id
}