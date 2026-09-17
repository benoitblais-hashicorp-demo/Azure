# terraform-azurerm-vm

Terraform module that provisions an Azure virtual machine (Linux or Windows) with a network interface and an optional extra data disk.

Designed as a lightweight proof-of-concept module. It covers the core use case and nothing more.

## Permissions

The identity running this module requires the following Azure RBAC roles on the target resource group:

- **Contributor** — to create the VM, NIC, and managed disk.

## Authentication

Configure the `azurerm` provider before calling this module. The standard approach is to set the following environment variables:

| Variable | Description |
|---|---|
| `ARM_CLIENT_ID` | Service principal or managed identity client ID |
| `ARM_CLIENT_SECRET` | Service principal secret |
| `ARM_SUBSCRIPTION_ID` | Target Azure subscription |
| `ARM_TENANT_ID` | Azure AD tenant ID |

## Features

- Linux (`azurerm_linux_virtual_machine`) or Windows (`azurerm_windows_virtual_machine`) VM, controlled via `os_type`.
- Network interface attached to an existing subnet.
- Optional extra data disk (`data_disk_size_gb = 0` skips creation).
- All resources tagged via a single `tags` variable.

## Usage example

```hcl
module "vm" {
  source  = "app.terraform.io/<org>/vm/azurerm"
  version = "0.0.1"

  name                = "poc-vm-01"
  resource_group_name = "rg-poc"
  location            = "canadacentral"
  subnet_id           = "/subscriptions/.../subnets/default"
  admin_username      = "azureadmin"
  admin_password      = var.vm_password   # pass via TF_VAR or workspace variable

  vm_size          = "Standard_B2s"
  os_type          = "Linux"
  data_disk_size_gb = 64

  tags = {
    environment = "poc"
    owner       = "platform-team"
  }
}
```

## Requirements

| Name | Version |
|---|---|
| terraform | >= 1.13.0 |
| azurerm | >= 4.42, < 5.0 |

## Required Inputs

| Name | Description |
|---|---|
| `name` | Name prefix for the VM and related resources |
| `resource_group_name` | Existing resource group name |
| `location` | Azure region |
| `subnet_id` | Resource ID of the target subnet |
| `admin_username` | VM local administrator username |
| `admin_password` | VM local administrator password *(sensitive)* |

## Optional Inputs

| Name | Default | Description |
|---|---|---|
| `vm_size` | `Standard_B2s` | Azure VM SKU |
| `os_type` | `Linux` | `Linux` or `Windows` |
| `source_image_reference` | Ubuntu 22.04 LTS Gen2 | Marketplace image reference |
| `os_disk_storage_account_type` | `StandardSSD_LRS` | OS disk storage type |
| `data_disk_size_gb` | `64` | Extra data disk size in GB (0 = no disk) |
| `data_disk_storage_account_type` | `StandardSSD_LRS` | Data disk storage type |
| `tags` | `{}` | Tags applied to all resources |

## Resources

| Type | Name |
|---|---|
| `azurerm_network_interface` | `this` |
| `azurerm_linux_virtual_machine` | `this` |
| `azurerm_windows_virtual_machine` | `this` |
| `azurerm_managed_disk` | `data` |
| `azurerm_virtual_machine_data_disk_attachment` | `data` |

## Outputs

| Name | Description |
|---|---|
| `vm_id` | Resource ID of the virtual machine |
| `vm_name` | Name of the virtual machine |
| `private_ip_address` | Private IP address of the NIC |
| `network_interface_id` | Resource ID of the NIC |
| `data_disk_id` | Resource ID of the data disk (empty string if none) |
