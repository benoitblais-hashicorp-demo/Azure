variable "organization_name" {
  description = "(Required) Name of the organization."
  type        = string
  nullable    = false
}

variable "project_description" {
  description = "(Optional) A description for the project."
  type        = string
  nullable    = true
  default     = null
}

variable "project_name" {
  description = "(Optional) Name of the project."
  type        = string
  nullable    = true
  default     = "Terraform Projects Factory"
}

variable "project_tags" {
  description = "(Optional) A map of key-value tags to add to the project."
  type        = map(string)
  nullable    = true
  default     = null
}
