# modules/network/outputs.tf
output "vnet_id" {
  description = "ID of the created virtual network"
  value       = azurerm_virtual_network.vnet.id
}

output "subnet_id" {
  description = "ID of the created subnet"
  value       = azurerm_subnet.subnet.id
}
