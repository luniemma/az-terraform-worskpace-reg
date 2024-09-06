resource "azurerm_databricks_workspace" "databricks" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "standard"
}

variable "name" {
  description = "Name of the Azure Databricks workspace"
  type        = string
}

variable "location" {
  description = "Azure region to deploy the Databricks workspace"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

output "workspace_url" {
  description = "The URL of the Azure Databricks workspace"
  value       = azurerm_databricks_workspace.databricks.workspace_url
}