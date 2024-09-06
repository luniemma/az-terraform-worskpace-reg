# outputs.tf
output "windows_vm_id" {
  description = "ID of the Windows VM"
  value       = module.windows_vm.vm_id
}

output "windows_vm_ip" {
  description = "Public IP of the Windows VM"
  value       = module.windows_vm.vm_public_ip
}

output "ubuntu_vm_ids" {
  description = "IDs of the Ubuntu VMs"
  value       = module.ubuntu_vms[*].vm_id
}

output "ubuntu_vm_ips" {
  description = "Public IPs of the Ubuntu VMs"
  value       = module.ubuntu_vms[*].vm_public_ip
}

output "rhel_vm_id" {
  description = "ID of the RHEL VM"
  value       = module.rhel_vm.vm_id
}

output "rhel_vm_ip" {
  description = "Public IP of the RHEL VM"
  value       = module.rhel_vm.vm_public_ip
}
