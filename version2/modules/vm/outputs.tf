# modules/vm/outputs.tf
output "vm_id" {
  description = "ID of the created VM"
  value       = var.os_type == "windows" ? azurerm_windows_virtual_machine.vm_windows[0].id : azurerm_linux_virtual_machine.vm_linux[0].id
}

output "vm_public_ip" {
  description = "Public IP of the created VM"
  value       = azurerm_public_ip.pip.ip_address
}