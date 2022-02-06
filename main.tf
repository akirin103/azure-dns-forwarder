data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

data "template_file" "script" {
  template = file("${path.module}/cloud-init.yml")
}

data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = data.template_file.script.rendered
  }
}

resource "azurerm_linux_virtual_machine" "this" {
  name                = "dns-forwarder"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location
  size                = var.virtual_machine_size
  admin_username      = "azureuser"
  custom_data = data.template_cloudinit_config.config.rendered
  network_interface_ids = [
    azurerm_network_interface.this.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file(var.ssh_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = var.tags

  depends_on = [
    azurerm_network_interface.this,
  ]
}

resource "azurerm_network_interface" "this" {
  name                = "dns-forwarder-nic"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.vnet_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address = var.private_ip_address
    public_ip_address_id = azurerm_public_ip.this.id
  }

  tags = var.tags

  depends_on = [
    azurerm_public_ip.this,
  ]
}

resource "azurerm_network_security_group" "this" {
  name                = "dns-forwarder-nsg"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location

  tags = var.tags
}

resource "azurerm_network_security_rule" "this" {
  name                        = "allow_remote_all"
  resource_group_name         = data.azurerm_resource_group.this.name
  description                 = "Allow remote protocol in from all locations"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefixes     = var.source_address_prefix
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.this.name

  depends_on = [
    azurerm_network_security_group.this,
  ]
}

resource "azurerm_network_interface_security_group_association" "this" {
  network_interface_id      = azurerm_network_interface.this.id
  network_security_group_id = azurerm_network_security_group.this.id

  depends_on = [
    azurerm_network_interface.this,
    azurerm_network_security_group.this,
  ]
}

resource "azurerm_public_ip" "this" {
  name                = "dns-forwarder-public-ip"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location
  allocation_method   = "Dynamic"
  tags = var.tags
}
