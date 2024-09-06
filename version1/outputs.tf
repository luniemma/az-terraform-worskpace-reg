# outputs.tf
output "vm_ids" {
  description = "IDs of the created VMs"
  value       = module.vm[*].vm_id
}

output "vm_ips" {
  description = "Public IPs of the created VMs"
  value       = module.vm[*].vm_public_ip
}
