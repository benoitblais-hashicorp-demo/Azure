# ---------------------------------------------------------------------------
# Required
# ---------------------------------------------------------------------------

variable "name" {
  type        = string
  description = "Name prefix used to name the VM and related resources."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the existing resource group where resources will be deployed."
}

variable "location" {
  type        = string
  description = "Azure region where resources will be deployed."
}

variable "subnet_id" {
  type        = string
  description = "Resource ID of the subnet to attach the VM network interface to."
}

variable "admin_username" {
  type        = string
  description = "Local administrator username for the virtual machine."
}

variable "admin_password" {
  type        = string
  description = "Local administrator password for the virtual machine. Stored as a sensitive value."
  sensitive   = true
}

# ---------------------------------------------------------------------------
# VM configuration
# ---------------------------------------------------------------------------

variable "vm_size" {
  type        = string
  description = "Azure VM SKU size (e.g. Standard_B2s)."
  default     = "Standard_B2s"
}

variable "os_type" {
  type        = string
  description = "Operating system type. Accepted values: Linux, Windows."
  default     = "Linux"

  validation {
    condition     = contains(["Linux", "Windows"], var.os_type)
    error_message = "os_type must be either 'Linux' or 'Windows'."
  }
}

variable "source_image_reference" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  description = "Marketplace image reference for the OS disk."
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

variable "os_disk_storage_account_type" {
  type        = string
  description = "Storage type for the OS disk. Accepted values: Standard_LRS, StandardSSD_LRS, Premium_LRS."
  default     = "StandardSSD_LRS"
}

# ---------------------------------------------------------------------------
# Extra data disk
# ---------------------------------------------------------------------------

variable "data_disk_size_gb" {
  type        = number
  description = "Size in GB of the extra data disk. Set to 0 to skip creating a data disk."
  default     = 64
}

variable "data_disk_storage_account_type" {
  type        = string
  description = "Storage type for the data disk. Accepted values: Standard_LRS, StandardSSD_LRS, Premium_LRS."
  default     = "StandardSSD_LRS"
}

# ---------------------------------------------------------------------------
# Tags
# ---------------------------------------------------------------------------

variable "tags" {
  type        = map(string)
  description = "Map of tags to apply to all resources."
  default     = {}
}
