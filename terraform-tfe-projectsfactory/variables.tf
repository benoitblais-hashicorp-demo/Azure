variable "project_name" {
  description = "(Required) Name of the project."
  type        = string
  nullable    = false
}

# It is required to specify the organization when creating a project.
# The value is set to null by default to not force the user to provide a value.
# The value is supposed to be provided through the variable set injected by HCPTerraform-ProjectsFactory.

variable "organization_name" {
  description = "(Optional) Name of the HCP Terraform organization. Configured automatically via the project variable set."
  type        = string
  nullable    = true
  default     = null
}

variable "project_description" {
  description = "(Optional) A description for the project."
  type        = string
  nullable    = true
  default     = null
}

variable "project_tags" {
  description = "(Optional) A map of key-value tags to add to the project."
  type        = map(string)
  nullable    = true
  default     = null
}

variable "sso_read_team_id" {
  description = "(Optional) The SSO team ID to associate with the read access team."
  type        = string
  nullable    = true
  default     = null
}

variable "sso_write_team_id" {
  description = "(Optional) The SSO team ID to associate with the write access team."
  type        = string
  nullable    = true
  default     = null
}

variable "variable_set_variables" {
  description = <<EOT
  (Optional) The variable_set_variables is a list of object supporting the following attributes:
    key         : (Required) Name of the variable.
    value       : (Required) Value of the variable.
    category    : (Required) Whether this is a Terraform or environment variable. Valid values are `terraform` or `env`.
    description : (Optional) Description of the variable.
    hcl         : (Optional) Whether to evaluate the value of the variable as a string of HCL code. Has no effect for environment variables. Defaults to `false`.
    sensitive   : (Optional) Whether the value is sensitive. If true then the variable is written once and not visible thereafter. Defaults to `false`.
  EOT
  type = list(object({
    key         = string
    value       = string
    category    = string
    description = optional(string)
    hcl         = optional(bool, false)
    sensitive   = optional(bool, false)
  }))
  nullable = true
  default  = []
}
