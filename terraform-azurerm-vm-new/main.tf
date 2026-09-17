locals {
  create_data_disk = var.data_disk_size_gb > 0
}

# ---------------------------------------------------------------------------
# Network interface
# ---------------------------------------------------------------------------

resource "azurerm_network_interface" "this" {
  name                = "${var.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# ---------------------------------------------------------------------------
# Linux virtual machine
# ---------------------------------------------------------------------------

resource "azurerm_linux_virtual_machine" "this" {
  count = lower(var.os_type) == "linux" ? 1 : 0

  name                            = var.name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = var.vm_size
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.this.id]
  tags                            = var.tags

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_storage_account_type
  }

  source_image_reference {
    publisher = var.source_image_reference.publisher
    offer     = var.source_image_reference.offer
    sku       = var.source_image_reference.sku
    version   = var.source_image_reference.version
  }
}

# ---------------------------------------------------------------------------
# Windows virtual machine
# ---------------------------------------------------------------------------

resource "azurerm_windows_virtual_machine" "this" {
  count = lower(var.os_type) == "windows" ? 1 : 0

  name                  = var.name
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = var.vm_size
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.this.id]
  tags                  = var.tags

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_storage_account_type
  }

  source_image_reference {
    publisher = var.source_image_reference.publisher
    offer     = var.source_image_reference.offer
    sku       = var.source_image_reference.sku
    version   = var.source_image_reference.version
  }
}

# ---------------------------------------------------------------------------
# Extra data disk
# ---------------------------------------------------------------------------

resource "azurerm_managed_disk" "data" {
  count = local.create_data_disk ? 1 : 0

  name                 = "${var.name}-datadisk-0"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = var.data_disk_storage_account_type
  create_option        = "Empty"
  disk_size_gb         = var.data_disk_size_gb
  tags                 = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "data" {
  count = local.create_data_disk ? 1 : 0

  managed_disk_id    = azurerm_managed_disk.data[0].id
  virtual_machine_id = lower(var.os_type) == "linux" ? azurerm_linux_virtual_machine.this[0].id : azurerm_windows_virtual_machine.this[0].id
  lun                = 0
  caching            = "ReadWrite"
}
