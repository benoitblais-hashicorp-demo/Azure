# The following variables are injected automatically as workspace-level Terraform variables
# by HCPTerraform-Foundation. They do not need to be set manually.

variable "azuredevops_organization" {
  description = "(Optional) The name of the Azure DevOps organization (the segment after `dev.azure.com/` in the URL). Injected automatically by HCPTerraform-Foundation via the workspace variable configuration."
  type        = string
  nullable    = true
  default     = null
}

variable "azuredevops_project_name" {
  description = "(Optional) The name of the Azure DevOps project where workspaces repositories live. Injected automatically by HCPTerraform-Foundation via the workspace variable configuration."
  type        = string
  nullable    = true
  default     = null
}

variable "organization_name" {
  description = "(Required) Name of the HCP Terraform organization."
  type        = string
  nullable    = false
}

variable "vcs_oauth_token_id" {
  description = "(Required) The OAuth Token ID of the HCP Terraform VCS Provider connection to use for workspaces. Find it in the HCP Terraform UI: Organization Settings → VCS Providers → click the connection → the value starts with `ot-`."
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
  description = "(Optional) Name of the HCP Terraform project."
  type        = string
  nullable    = true
  default     = "Terraform Workspaces Factory"
}

variable "project_tags" {
  description = "(Optional) A map of key-value tags to add to the project."
  type        = map(string)
  nullable    = true
  default     = null
}
