provider "azurerm" {
  subscription_id = "606e824b-aaf7-4b4e-9057-b459f6a4436d"
   features {}

}

resource "azurerm_resource_group" "clouddevopshq_rg" {
  name     = "cloudDevopsHQ-sqldb-rg"
  location = "West Europe"
}

resource "azurerm_mssql_server" "clouddevopshq_sqlserver" {
  name                         = "clouddevopshq-sqlserver"
  resource_group_name          = azurerm_resource_group.clouddevopshq_rg.name
  location                     = azurerm_resource_group.clouddevopshq_rg.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "P@ssw0rd1234!"

  tags = {
    environment = "production"
  }
}

resource "azurerm_mssql_database" "clouddevopshq_db" {
  name           = "clouddevopshq-db"
  server_id      = azurerm_mssql_server.clouddevopshq_sqlserver.id
  sku_name       = "S0"
  zone_redundant = false

  tags = {
    environment = "production"
  }
}

output "sql_server_name" {
  value = azurerm_mssql_server.clouddevopshq_sqlserver.name
}

output "sql_database_name" {
  value = azurerm_mssql_database.clouddevopshq_db.name
}
