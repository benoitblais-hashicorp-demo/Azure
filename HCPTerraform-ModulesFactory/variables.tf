variable "azuredevops_organization" {
  description = "(Required) The name of the Azure DevOps organization (the segment after `dev.azure.com/` in the URL). Used to build the VCS identifier for HCP Terraform workspaces."
  type        = string
  nullable    = false
}

variable "azuredevops_personal_access_token" {
  description = "(Required) The Azure DevOps Personal Access Token used to authenticate. Can also be set via the AZDO_PERSONAL_ACCESS_TOKEN environment variable."
  type        = string
  nullable    = false
  sensitive   = true
}

variable "azuredevops_project_name" {
  description = "(Required) The name of the Azure DevOps project in which all factory repositories will be created. Used to look up the project UUID at plan time."
  type        = string
  nullable    = false
}

variable "organization_name" {
  description = "(Required) Name of the HCP Terraform organization."
  type        = string
  nullable    = false
}

variable "tfe_token" {
  description = "(Required) HCP Terraform API token used by child workspaces to publish modules into the private registry."
  type        = string
  nullable    = false
  sensitive   = true
}

variable "vcs_oauth_token_id" {
  description = "(Required) The OAuth Token ID of the HCP Terraform VCS Provider connection to use for VCS-driven workspaces. Find it in the HCP Terraform UI: Organization Settings → VCS Providers → click the connection → the value starts with `ot-` (not `oc-`)."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^ot-", var.vcs_oauth_token_id))
    error_message = "The OAuth Token ID must start with `ot-`. You may have provided the OAuth Client ID (starts with `oc-`) instead."
  }
}

variable "azuredevops_service_url" {
  description = "(Optional) The base URL of the Azure DevOps service. Defaults to `https://dev.azure.com`. The full organization URL is constructed automatically as `<azuredevops_service_url>/<azuredevops_organization>`."
  type        = string
  nullable    = false
  default     = "https://dev.azure.com"
}

variable "module_name" {
  description = "(Optional) Name of the Terraform module used by the modules factory. Must follow the convention `terraform-<provider>-<name>`."
  type        = string
  nullable    = false
  default     = "terraform-tfe-modulesfactory"
}

variable "oauth_client_name" {
  description = "(Optional) Display name of the HCP Terraform VCS OAuth client (Azure DevOps VCS provider connection). Defaults to `Azure DevOps Services`, which is the name assigned by HCP Terraform when the connection is created through the UI."
  type        = string
  nullable    = false
  default     = "Azure DevOps Services"
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
  default     = "Terraform Modules Factory"
}

variable "project_tags" {
  description = "(Optional) A map of key-value tags to add to the project."
  type        = map(string)
  nullable    = true
  default     = null
}
