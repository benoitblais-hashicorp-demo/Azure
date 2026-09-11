variable "name" {
  description = "(Required) Name of the workspace."
  type        = string
  nullable    = false
}

variable "project_name" {
  description = "(Required) Name of the project where the workspace should be created."
  type        = string
  nullable    = false
}

variable "vcs_repo_name" {
  description = "(Required) Name of the Azure DevOps repository. Used together with `azuredevops_organization` and `azuredevops_project_name` to build the VCS identifier automatically."
  type        = string
  nullable    = false
}

variable "agent_pool_id" {
  description = "(Optional) The ID of an agent pool to assign to the workspace. Requires `execution_mode` to be set to `agent`. This value must not be provided if `execution_mode` is set to any other value."
  type        = string
  nullable    = true
  default     = null
}

variable "allow_destroy_plan" {
  description = "(Optional) Whether destroy plans can be queued on the workspace."
  type        = bool
  nullable    = false
  default     = true
}

variable "assessments_enabled" {
  description = "(Optional) Whether to regularly run health assessments such as drift detection on the workspace."
  type        = bool
  nullable    = false
  default     = false
}

variable "auto_apply" {
  description = "(Optional) Whether to automatically apply changes when a Terraform plan is successful."
  type        = bool
  nullable    = false
  default     = true
}

variable "auto_apply_run_trigger" {
  description = "(Optional) Whether to automatically apply changes for runs that were created by run triggers from another workspace."
  type        = bool
  nullable    = false
  default     = true
}

variable "description" {
  description = "(Optional) A description for the workspace."
  type        = string
  nullable    = true
  default     = null
}

variable "execution_mode" {
  description = "(Optional) Which execution mode to use. Valid values are `remote`, `local` or `agent`. When set to `local`, the workspace will be used for state storage only. If omitted, the workspace uses the organization's default execution mode."
  type        = string
  nullable    = true
  default     = null

  validation {
    condition     = var.execution_mode != null ? contains(["remote", "local", "agent"], var.execution_mode) : true
    error_message = "Valid values are `remote`, `local` or `agent`."
  }
}

variable "file_triggers_enabled" {
  description = "(Optional) Whether to filter runs based on the changed files in a VCS push. If enabled, the working directory and trigger prefixes describe a set of paths which must contain changes for a VCS push to trigger a run. If disabled, any push will trigger a run."
  type        = bool
  nullable    = false
  default     = true
}

variable "global_remote_state" {
  description = "(Optional) Whether the workspace allows all workspaces in the organization to access its state data during runs. If false, then only specifically approved workspaces can access its state (`remote_state_consumer_ids`)."
  type        = bool
  nullable    = false
  default     = false
}

# The following variables are configured automatically via the variable set injected by HCPTerraform-WorkspacesFactory.
# Their values are set to null by default so the module can be used without explicitly providing them.

variable "azuredevops_organization" {
  description = "(Optional) The name of the Azure DevOps organization (the segment after `dev.azure.com/` in the URL). Used together with `azuredevops_project_name` and `vcs_repo_name` to build the VCS identifier. Configured automatically via the project variable set."
  type        = string
  nullable    = true
  default     = null
}

variable "azuredevops_project_name" {
  description = "(Optional) The name of the Azure DevOps project where the repository lives. Spaces are URL-encoded automatically when building the VCS identifier. Configured automatically via the project variable set."
  type        = string
  nullable    = true
  default     = null
}

variable "organization_name" {
  description = "(Optional) Name of the HCP Terraform organization. Configured automatically via the project variable set."
  type        = string
  nullable    = true
  default     = null
}

variable "queue_all_runs" {
  description = "(Optional) Whether the workspace should start automatically performing runs immediately after its creation. When set to `false`, runs triggered by a webhook (such as a commit in VCS) will not be queued until at least one run has been manually queued."
  type        = bool
  nullable    = false
  default     = true
}

variable "remote_state_consumer_ids" {
  description = "(Optional) The set of workspace IDs set as explicit remote state consumers for the given workspace."
  type        = set(string)
  nullable    = false
  default     = []
}

variable "run_tasks" {
  description = <<EOT
  (Optional) A list of run tasks to be executed on the workspace.
    task_id           : (Required) The id of the Run task to associate to the workspace.
    enforcement_level : (Optional) The enforcement level of the task. Valid values are `advisory` and `mandatory`.
    stages            : (Optional) The stages to run the task in. Valid values are one or more of `pre_plan`, `post_plan`, `pre_apply` and `post_apply`.
  EOT
  type = list(object({
    task_id           = string
    enforcement_level = optional(string, "advisory")
    stages            = optional(list(string), [])
  }))
  nullable = true
  default  = []

  validation {
    condition = var.run_tasks == null || length(var.run_tasks) == 0 ? true : alltrue([
      for value in var.run_tasks : contains(["advisory", "mandatory"], value.enforcement_level)
    ])
    error_message = "Valid values for `enforcement_level` are `advisory` and `mandatory`."
  }
  validation {
    condition = var.run_tasks == null || length(var.run_tasks) == 0 ? true : alltrue([
      for value in var.run_tasks : alltrue([
        for stage in value.stages :
        contains(["pre_plan", "post_plan", "pre_apply", "post_apply"], stage)
      ])
    ])
    error_message = "Valid values for `stages` are `pre_plan`, `post_plan`, `pre_apply`, and `post_apply`."
  }
}

variable "source_name" {
  description = "(Optional) A friendly name for the application or client creating this workspace. If set, this will be displayed on the workspace as 'Created via <source_name>'. Requires `source_url` to also be set."
  type        = string
  nullable    = true
  default     = null
}

variable "source_url" {
  description = "(Optional) A URL for the application or client creating this workspace. Requires `source_name` to also be set. Note: cannot be updated after workspace creation — modifying this value will replace the workspace."
  type        = string
  nullable    = true
  default     = null
}

variable "speculative_enabled" {
  description = "(Optional) Whether this workspace allows speculative plans. Setting this to `false` prevents Terraform Cloud or the Terraform Enterprise instance from running plans on pull requests."
  type        = bool
  nullable    = false
  default     = true
}

variable "ssh_key_id" {
  description = "(Optional) The ID of an SSH key to assign to the workspace."
  type        = string
  nullable    = true
  default     = null
}

variable "structured_run_output_enabled" {
  description = "(Optional) Whether this workspace should show output from Terraform runs using the enhanced UI when available. Setting this to `false` ensures that all runs in this workspace will display their output as text logs."
  type        = bool
  nullable    = false
  default     = false
}

variable "tags" {
  description = "(Optional) A map of key-value tags for this workspace."
  type        = map(string)
  nullable    = true
  default     = null
}

variable "terraform_version" {
  description = "(Optional) The version of Terraform to use for this workspace. This can be either an exact version or a version constraint (like `~> 1.0.0`). Defaults to `latest`."
  type        = string
  nullable    = false
  default     = "latest"
}

variable "trigger_patterns" {
  description = "(Optional) List of glob patterns that describe the files Terraform Cloud monitors for changes. Trigger patterns are always appended to the root directory of the repository. Mutually exclusive with `trigger_prefixes`."
  type        = list(string)
  nullable    = true
  default     = ["*.tf"]
}

variable "trigger_prefixes" {
  description = "(Optional) List of repository-root-relative paths which describe all locations to be tracked for changes. Mutually exclusive with `trigger_patterns`."
  type        = list(string)
  nullable    = true
  default     = null
}

variable "variables" {
  description = <<EOT
  (Optional) List of variables to add to the workspace.
    key         : (Required) Name of the variable.
    value       : (Required) Value of the variable.
    category    : (Required) Whether this is a Terraform or environment variable. Valid values are `terraform` or `env`.
    description : (Optional) Description of the variable.
    hcl         : (Optional) Whether to evaluate the value of the variable as HCL. Defaults to `false`.
    sensitive   : (Optional) Whether the value is sensitive. Defaults to `false`.
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

variable "working_directory" {
  description = "(Optional) A relative path that Terraform will execute within. Defaults to the root of your repository."
  type        = string
  nullable    = true
  default     = null
}

variable "vcs_repo_branch" {
  description = "(Optional) The repository branch that Terraform will execute from. This defaults to the repository's default branch (e.g. main)."
  type        = string
  nullable    = true
  default     = null
}

variable "vcs_repo_identifier" {
  description = "(Optional) Override for the full VCS identifier passed to HCP Terraform. Use this only when `vcs_repo_name`, `azuredevops_organization`, and `azuredevops_project_name` are not sufficient. For Azure DevOps the format is `<org>/<project%20url-encoded>/_git/<repo>`. When set, this takes precedence over the automatically built identifier."
  type        = string
  nullable    = true
  default     = null
}

variable "vcs_repo_ingress_submodules" {
  description = "(Optional) Whether submodules should be fetched when cloning the VCS repository."
  type        = bool
  nullable    = false
  default     = false
}

variable "vcs_repo_oauth_token_id" {
  description = "(Optional) The VCS Connection OAuth Token ID used to authenticate with Azure DevOps. Injected automatically via the project variable set configured by HCPTerraform-WorkspacesFactory."
  type        = string
  nullable    = true
  default     = null
}

variable "vcs_repo_github_app_installation_id" {
  description = "(Optional) The installation id of the GitHub App. Conflicts with `vcs_repo_oauth_token_id`."
  type        = string
  nullable    = true
  default     = null

  validation {
    condition     = var.vcs_repo_oauth_token_id != null && var.vcs_repo_github_app_installation_id != null ? false : true
    error_message = "`vcs_repo_oauth_token_id` conflicts with `vcs_repo_github_app_installation_id`."
  }
}

variable "vcs_repo_tags_regex" {
  description = "(Optional) A regular expression used to trigger a workspace run for matching Git tags. Conflicts with `trigger_patterns` and `trigger_prefixes`."
  type        = string
  nullable    = true
  default     = null
}