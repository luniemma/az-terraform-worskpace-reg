# resource group name
variable "resource_group_name" {
    description = "Name of the resource group"
    type = string
    default = "cloudddatadevops-rg"
}
# variable resource group location
variable "location" {
    description = "Location of the resource group"
    type = string
    default = "East US"
}
# data factory variable name
variable "data_factory_name" {
    description = "Name of the data factory"
    type = string
    default = "adf-clouddatadevops-001"
}

# databricks variable name
variable "databricks_name" {
    description = "Databricks workspace name"
    type = string
    default = "dbw-clouddatadevops-001"
}
