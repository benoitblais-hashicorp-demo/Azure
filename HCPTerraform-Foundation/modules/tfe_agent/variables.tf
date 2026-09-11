variable "name" {
  description = "(Required) Name of the agent pool."
  type        = string
}

variable "organization" {
  description = "(Optional) Name of the organization. If omitted, organization must be defined in the provider config."
  type        = string
  default     = null
}

variable "organization_scoped" {
  description = "(Optional) Whether or not the agent pool is scoped to all workspaces in the organization."
  type        = bool
  default     = true
}

variable "token_description" {
  description = "(Optional) Description of the agent token."
  type        = list(string)
  default     = null
}
