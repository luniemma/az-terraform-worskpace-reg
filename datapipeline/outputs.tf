output "resource_group_id" {
  description = "The ID of the resource group"
  value       = azurerm_resource_group.rg.id
}

output "data_factory_id" {
  description = "The ID of the Azure Data Factory"
  value       = module.data_factory.data_factory_id
}

output "databricks_workspace_url" {
  description = "The URL of the Azure Databricks workspace"
  value       = module.databricks.workspace_url
}