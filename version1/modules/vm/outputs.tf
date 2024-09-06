# modules/vm/outputs.tf
output "vm_id" {
  description = "ID of the created VM"
  value       = azurerm_linux_virtual_machine.vm.id
}

output "vm_public_ip" {
  description = "Public IP of the created VM"
  value       = azurerm_public_ip.pip.ip_address
}
