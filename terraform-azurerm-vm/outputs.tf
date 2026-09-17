output "vm_id" {
  description = "Resource ID of the virtual machine."
  value       = lower(var.os_type) == "linux" ? azurerm_linux_virtual_machine.this[0].id : azurerm_windows_virtual_machine.this[0].id
}

output "vm_name" {
  description = "Name of the virtual machine."
  value       = lower(var.os_type) == "linux" ? azurerm_linux_virtual_machine.this[0].name : azurerm_windows_virtual_machine.this[0].name
}

output "private_ip_address" {
  description = "Private IP address assigned to the VM network interface."
  value       = azurerm_network_interface.this.private_ip_address
}

output "network_interface_id" {
  description = "Resource ID of the VM network interface."
  value       = azurerm_network_interface.this.id
}

output "data_disk_id" {
  description = "Resource ID of the extra data disk. Empty string when no data disk was created."
  value       = local.create_data_disk ? azurerm_managed_disk.data[0].id : ""
}
