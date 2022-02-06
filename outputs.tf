output "instance_ip_addr" {
  value       = azurerm_linux_virtual_machine.this.id
  description = "VirtualMachine(DNS Forwarder)のID"
}