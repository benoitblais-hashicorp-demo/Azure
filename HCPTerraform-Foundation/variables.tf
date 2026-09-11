variable "organization_email" {
  description = "(Required) Admin email address."
  type        = string
  nullable    = false
}

variable "organization_name" {
  description = "(Required) Name of the organization."
  type        = string
  nullable    = false
}

variable "user_tokens_enabled" {
  description = "(Optional) Whether user tokens can be used to read or update the organization."
  type        = bool
  default     = true
}

variable "agent_pools" {
  description = "(Optional) A list with the name of all the agent pools available at the organization level."
  type        = list(string)
  nullable    = false
  default     = []
}

variable "aggregated_commit_status_enabled" {
  description = "(Optional) Whether or not to enable Aggregated Status Checks. This can be useful for monorepo repositories with multiple workspaces receiving status checks for events such as a pull request. If enabled, send_passing_statuses_for_untriggered_speculative_plans needs to be false. Default to `true`."
  type        = bool
  default     = true

  validation {
    condition     = var.aggregated_commit_status_enabled ? var.send_passing_statuses_for_untriggered_speculative_plans == false ? true : false : true
    error_message = "If `aggregated_commit_status_enabled` is enabled, `send_passing_statuses_for_untriggered_speculative_plans` needs to be false."
  }
}

variable "allow_force_delete_workspaces" {
  description = "(Optional) Whether workspace administrators are permitted to delete workspaces with resources under management. If false, only organization owners may delete these workspaces. Defaults to `false`."
  type        = bool
  default     = false
}

variable "assessments_enforced" {
  description = "(Optional) Whether to force health assessments (drift detection) on all eligible workspaces or allow workspaces to set their own preferences. Default to `true`."
  type        = bool
  default     = true
}

variable "collaborator_auth_policy" {
  description = "(Optional) Authentication policy. Valid values are `password` or `two_factor_mandatory`. Default to `two_factor_mandatory`."
  type        = string
  nullable    = false
  default     = "two_factor_mandatory"

  validation {
    condition     = contains(["password", "two_factor_mandatory"], var.collaborator_auth_policy) ? true : false
    error_message = "Valid values are \"password\" or \"two_factor_mandatory\"."
  }
}

variable "cost_estimation_enabled" {
  description = "(Optional) Whether or not the cost estimation feature is enabled for all workspaces in the organization. Defaults to `true`."
  type        = bool
  default     = true
}

# variable "default_agent_pool_id" {
#   description = "(Optional) The ID of an agent pool to assign to the workspace. Requires `default_execution_mode` to be set to `agent`. This value must not be provided if `default_execution_mode` is set to any other value."
#   type        = string
#   nullable    = true
#   default     = null
# }

variable "default_execution_mode" {
  description = " (Optional) Which execution mode to use as the default for all workspaces in the organization. Valid values are `remote`, `local` or `agent`. Default to `remote`."
  type        = string
  nullable    = false
  default     = "remote"

  validation {
    condition     = contains(["remote", "local", "agent"], var.default_execution_mode) ? true : false
    error_message = "Valid values are \"remote\", \"local\", or \"agent\"."
  }
}

variable "hcp_foundation_project_description" {
  description = "(Optional) A description for the project in HCP Terraform."
  type        = string
  nullable    = true
  default     = null
}

variable "hcp_foundation_project_name" {
  description = "(Optional) Name of the project in HCP Terraform."
  type        = string
  nullable    = true
  default     = "HCP Terraform"
}

variable "hcp_foundation_project_tags" {
  description = "(Optional) A map of key-value tags to add to the project in HCP Terraform."
  type        = map(string)
  nullable    = true
  default     = null
}

variable "owners_team_saml_role_id" {
  description = "(Optional) The name of the \"owners\" team."
  type        = string
  nullable    = true
  default     = null
}

variable "send_passing_statuses_for_untriggered_speculative_plans" {
  description = "(Optional) Whether or not to send VCS status updates for untriggered speculative plans. This can be useful if large numbers of untriggered workspaces are exhausting request limits for connected version control service providers like GitHub. Defaults to `false`."
  type        = bool
  default     = false
}

variable "session_remember_minutes" {
  description = "(Optional) Session expiration. Defaults to `20160`."
  type        = number
  nullable    = true
  default     = null
}

variable "session_timeout_minutes" {
  description = "(Optional) Session timeout after inactivity. Defaults to `20160`."
  type        = number
  nullable    = true
  default     = null
}

variable "speculative_plan_management_enabled" {
  description = "(Optional) Whether or not to enable Speculative Plan Management. If true, pending VCS-triggered speculative plans from outdated commits will be cancelled if a newer commit is pushed to the same branch. default to `true`."
  type        = bool
  default     = true
}

variable "stacks_enabled" {
  description = "(Optional) Whether or not to enable Stacks. Defaults to `true`."
  type        = bool
  default     = true
}

variable "teams" {
  description = <<EOT
  (Optional) The teams block supports the following:
    name                         : (Required) Name of the team. 
    organization_access          : (Optional) The organization_access supports the following:
      access_secret_teams        : (Optional) Allow members access to secret teams up to the level of permissions granted by their team permissions setting.
      manage_agent_pools         : (Optional) Allow members to create, edit, and delete agent pools within their organization.
      manage_membership          : (Optional) Allow members to add/remove users from the organization, and to add/remove users from visible teams.
      manage_modules             : (Optional) Allow members to publish and delete modules in the organization's private registry.
      manage_organization_access : (Optional) Allow members to update the organization access settings of teams.
      manage_policies            : (Optional) Allows members to create, edit, and delete the organization's Sentinel policies.
      manage_policy_overrides    : (Optional) Allows members to override soft-mandatory policy checks.
      manage_projects            : (Optional) Allow members to create and administrate all projects within the organization.
      manage_providers           : (Optional) Allow members to publish and delete providers in the organization's private registry.
      manage_run_tasks           : (Optional) Allow members to create, edit, and delete the organization's run tasks.
      manage_teams               : (Optional) Allow members to create, update, and delete teams.
      manage_vcs_settings        : (Optional) Allows members to manage the organization's VCS Providers and SSH keys.
      manage_workspaces          : (Optional) Allows members to create and administrate all workspaces within the organization.
      read_projects              : (Optional) Allow members to view all projects within the organization. Requires read_workspaces to be set to true.
      read_workspaces            : (Optional) Allow members to view all workspaces in this organization.
    sso_team_id                  : (Optional) Unique Identifier to control team membership via SAML.
    token                        : (Optional) If set to `true`, a team token will be generated. The token expiration is automatically set to 24 months from the time of creation.
    token_description            : (Optional) The token's description, which must be unique per team. Required if creating multiple tokens for a single team.
    token_force_regenerate       : (Optional) If set to `true`, a new token will be generated even if a token already exists. This will invalidate the existing token!
    visibility                   : (Optional) The visibility of the team (`secret` or `organization`).
  EOT
  type = list(object({
    name = string
    organization_access = optional(object({
      access_secret_teams        = optional(bool, false)
      manage_agent_pools         = optional(bool, false)
      manage_membership          = optional(bool, false)
      manage_modules             = optional(bool, false)
      manage_organization_access = optional(bool, false)
      manage_policies            = optional(bool, false)
      manage_policy_overrides    = optional(bool, false)
      manage_projects            = optional(bool, false)
      manage_providers           = optional(bool, false)
      manage_run_tasks           = optional(bool, false)
      manage_teams               = optional(bool, false)
      manage_vcs_settings        = optional(bool, false)
      manage_workspaces          = optional(bool, false)
      read_projects              = optional(bool, false)
      read_workspaces            = optional(bool, false)
    }), null)
    sso_team_id            = optional(string)
    token                  = optional(bool, false)
    token_description      = optional(string)
    token_force_regenerate = optional(bool, false)
    visibility             = optional(string, "organization")
  }))
  nullable = false
  default  = []

  validation {
    condition     = length([for team in var.teams : team.organization_access != null ? team.organization_access.read_projects != false && team.organization_access.manage_projects != false ? false : true : true]) == length(var.teams)
    error_message = "Project access must be `read` or `manage`."
  }

  validation {
    condition     = length([for team in var.teams : team.organization_access != null ? team.organization_access.read_workspaces != false && team.organization_access.manage_workspaces != false ? false : true : true]) == length(var.teams)
    error_message = "Workspaces access must be `read` or `manage`."
  }

  validation {
    condition     = length([for team in var.teams : team.organization_access != null ? team.organization_access.manage_projects == true && team.organization_access.manage_workspaces != true ? false : true : true]) == length(var.teams)
    error_message = "`manage_projects` requires `manage_workspaces` to be set to `true`."
  }
  validation {
    condition     = length([for team in var.teams : contains(["secret", "organization"], team.visibility)]) == length(var.teams)
    error_message = "Valid values for `visibility` is \"secret\" or \"organization\"."
  }
}

# *********************************************************************************************** #
#                                       Policies Factory                                          #
# *********************************************************************************************** #

variable "policies_factory_workspace_name" {
  description = "(Optional) Name of the workspace for the `policies factory`."
  type        = string
  nullable    = true
  default     = "HCPTerraform-PoliciesFactory"
}

variable "policies_factory_agent_pool_id" {
  description = "(Optional) The ID of an agent pool to assign to the workspace for the `policies factory`. Requires `execution_mode` to be set to `agent`. This value must not be provided if `execution_mode` is set to any other value."
  type        = string
  nullable    = true
  default     = null
}

variable "policies_factory_description" {
  description = "(Optional) A description for the workspacel for the `policies factory`."
  type        = string
  nullable    = true
  default     = "Code to provision and manage HCP Terraform policies using Terraform code (IaC)."
}

variable "policies_factory_execution_mode" {
  description = "(Optional) Which execution mode to use for the `policies factory`. Using Terraform Cloud, valid values are `remote`, `local` or `agent`. When set to `local`, the workspace will be used for state storage only. Important: If you omit this attribute, the resource configures the workspace to use your organization's default execution mode (which in turn defaults to `remote`), removing any explicit value that might have previously been set for the workspace."
  type        = string
  nullable    = true
  default     = null

  validation {
    condition     = var.policies_factory_execution_mode != null ? contains(["null", "remote", "local", "agent"], var.policies_factory_execution_mode) ? true : false : true
    error_message = "Valid values are \"remote\", \"local\" or \"agent\"."
  }
}

variable "policies_factory_branch_policies" {
  description = "(Optional) Branch policy configurations for the `policies factory` Azure DevOps repository. See the `azuredevops_repository` module `branch_policies` variable for the full schema."
  type = list(object({
    branch_ref                 = string
    match_type                 = optional(string, "Exact")
    enabled                    = optional(bool, true)
    blocking                   = optional(bool, true)
    require_comment_resolution = optional(bool, false)
    min_reviewers = optional(object({
      reviewer_count                         = number
      submitter_can_vote                     = optional(bool, false)
      last_pusher_cannot_approve             = optional(bool, true)
      allow_completion_with_rejects_or_waits = optional(bool, false)
      on_push_reset_approved_votes           = optional(bool, true)
      on_push_reset_all_votes                = optional(bool, false)
    }), null)
    merge_types = optional(object({
      allow_squash                  = optional(bool, true)
      allow_rebase_and_fast_forward = optional(bool, false)
      allow_basic_no_fast_forward   = optional(bool, true)
      allow_rebase_with_merge       = optional(bool, false)
    }), null)
    auto_reviewers = optional(object({
      reviewer_ids       = list(string)
      submitter_can_vote = optional(bool, false)
      message            = optional(string, null)
      path_filters       = optional(list(string), [])
    }), null)
  }))
  nullable = false
  default = [
    {
      branch_ref                 = "refs/heads/main"
      require_comment_resolution = true
      min_reviewers = {
        reviewer_count = 1
      }
      merge_types = {
        allow_squash            = true
        allow_basic_no_fast_forward = true
      }
    }
  ]
}

variable "policies_factory_tag" {
  description = "(Optional) A map of key value tags for this workspace for the `policies factory`."
  type        = map(string)
  nullable    = true
  default     = null
}

# *********************************************************************************************** #
#                                       Modules Factory                                          #
# *********************************************************************************************** #

variable "modules_factory_workspace_name" {
  description = "(Optional) Name of the workspace for the `modules factory`."
  type        = string
  nullable    = true
  default     = "HCPTerraform-ModulesFactory"
}

variable "modules_factory_agent_pool_id" {
  description = "(Optional) The ID of an agent pool to assign to the workspace for the `modules factory`. Requires `execution_mode` to be set to `agent`. This value must not be provided if `execution_mode` is set to any other value."
  type        = string
  nullable    = true
  default     = null
}

variable "modules_factory_description" {
  description = "(Optional) A description for the workspacel for the `modules factory`."
  type        = string
  nullable    = true
  default     = "Code to provision and manage HCP Terraform modules using Terraform code (IaC)."
}

variable "modules_factory_execution_mode" {
  description = "(Optional) Which execution mode to use for the `modules factory`. Using Terraform Cloud, valid values are `remote`, `local` or `agent`. When set to `local`, the workspace will be used for state storage only. Important: If you omit this attribute, the resource configures the workspace to use your organization's default execution mode (which in turn defaults to `remote`), removing any explicit value that might have previously been set for the workspace."
  type        = string
  nullable    = true
  default     = null

  validation {
    condition     = var.modules_factory_execution_mode != null ? contains(["null", "remote", "local", "agent"], var.modules_factory_execution_mode) ? true : false : true
    error_message = "Valid values are \"remote\", \"local\" or \"agent\"."
  }
}

variable "modules_factory_branch_policies" {
  description = "(Optional) Branch policy configurations for the `modules factory` Azure DevOps repository. See the `azuredevops_repository` module `branch_policies` variable for the full schema."
  type = list(object({
    branch_ref                 = string
    match_type                 = optional(string, "Exact")
    enabled                    = optional(bool, true)
    blocking                   = optional(bool, true)
    require_comment_resolution = optional(bool, false)
    min_reviewers = optional(object({
      reviewer_count                         = number
      submitter_can_vote                     = optional(bool, false)
      last_pusher_cannot_approve             = optional(bool, true)
      allow_completion_with_rejects_or_waits = optional(bool, false)
      on_push_reset_approved_votes           = optional(bool, true)
      on_push_reset_all_votes                = optional(bool, false)
    }), null)
    merge_types = optional(object({
      allow_squash                  = optional(bool, true)
      allow_rebase_and_fast_forward = optional(bool, false)
      allow_basic_no_fast_forward   = optional(bool, true)
      allow_rebase_with_merge       = optional(bool, false)
    }), null)
    auto_reviewers = optional(object({
      reviewer_ids       = list(string)
      submitter_can_vote = optional(bool, false)
      message            = optional(string, null)
      path_filters       = optional(list(string), [])
    }), null)
  }))
  nullable = false
  default = [
    {
      branch_ref                 = "refs/heads/main"
      require_comment_resolution = true
      min_reviewers = {
        reviewer_count = 1
      }
      merge_types = {
        allow_squash            = true
        allow_basic_no_fast_forward = true
      }
    }
  ]
}

variable "modules_factory_tag" {
  description = "(Optional) A map of key value tags for this workspace for the `modules factory`."
  type        = map(string)
  nullable    = true
  default     = null
}

# *********************************************************************************************** #
#                                       Projects Factory                                          #
# *********************************************************************************************** #

variable "projects_factory_workspace_name" {
  description = "(Optional) Name of the workspace for the `projects factory`."
  type        = string
  nullable    = true
  default     = "HCPTerraform-ProjectsFactory"
}

variable "projects_factory_agent_pool_id" {
  description = "(Optional) The ID of an agent pool to assign to the workspace for the `projects factory`. Requires `execution_mode` to be set to `agent`. This value must not be provided if `execution_mode` is set to any other value."
  type        = string
  nullable    = true
  default     = null
}

variable "projects_factory_description" {
  description = "(Optional) A description for the workspace for the `projects factory`."
  type        = string
  nullable    = true
  default     = "Code to provision and manage HCP Terraform projects using Terraform code (IaC)."
}

variable "projects_factory_execution_mode" {
  description = "(Optional) Which execution mode to use for the `projects factory`. Using Terraform Cloud, valid values are `remote`, `local` or `agent`. When set to `local`, the workspace will be used for state storage only. Important: If you omit this attribute, the resource configures the workspace to use your organization's default execution mode (which in turn defaults to `remote`), removing any explicit value that might have previously been set for the workspace."
  type        = string
  nullable    = true
  default     = null

  validation {
    condition     = var.projects_factory_execution_mode != null ? contains(["null", "remote", "local", "agent"], var.projects_factory_execution_mode) ? true : false : true
    error_message = "Valid values are \"remote\", \"local\" or \"agent\"."
  }
}

variable "projects_factory_branch_policies" {
  description = "(Optional) Branch policy configurations for the `projects factory` Azure DevOps repository. See the `azuredevops_repository` module `branch_policies` variable for the full schema."
  type = list(object({
    branch_ref                 = string
    match_type                 = optional(string, "Exact")
    enabled                    = optional(bool, true)
    blocking                   = optional(bool, true)
    require_comment_resolution = optional(bool, false)
    min_reviewers = optional(object({
      reviewer_count                         = number
      submitter_can_vote                     = optional(bool, false)
      last_pusher_cannot_approve             = optional(bool, true)
      allow_completion_with_rejects_or_waits = optional(bool, false)
      on_push_reset_approved_votes           = optional(bool, true)
      on_push_reset_all_votes                = optional(bool, false)
    }), null)
    merge_types = optional(object({
      allow_squash                  = optional(bool, true)
      allow_rebase_and_fast_forward = optional(bool, false)
      allow_basic_no_fast_forward   = optional(bool, true)
      allow_rebase_with_merge       = optional(bool, false)
    }), null)
    auto_reviewers = optional(object({
      reviewer_ids       = list(string)
      submitter_can_vote = optional(bool, false)
      message            = optional(string, null)
      path_filters       = optional(list(string), [])
    }), null)
  }))
  nullable = false
  default = [
    {
      branch_ref                 = "refs/heads/main"
      require_comment_resolution = true
      min_reviewers = {
        reviewer_count = 1
      }
      merge_types = {
        allow_squash            = true
        allow_basic_no_fast_forward = true
      }
    }
  ]
}

variable "projects_factory_tag" {
  description = "(Optional) A map of key value tags for this workspace for the `projects factory`."
  type        = map(string)
  nullable    = true
  default     = null
}

# *********************************************************************************************** #
#                                      Workspaces Factory                                         #
# *********************************************************************************************** #

variable "workspaces_factory_workspace_name" {
  description = "(Optional) Name of the workspace for the `workspaces factory`."
  type        = string
  nullable    = true
  default     = "HCPTerraform-WorkspacesFactory"
}

variable "workspaces_factory_agent_pool_id" {
  description = "(Optional) The ID of an agent pool to assign to the workspace for the `workspaces factory`. Requires `execution_mode` to be set to `agent`. This value must not be provided if `execution_mode` is set to any other value."
  type        = string
  nullable    = true
  default     = null
}

variable "workspaces_factory_description" {
  description = "(Optional) A description for the workspace for the `workspaces factory`."
  type        = string
  nullable    = true
  default     = "Code to provision and manage HCP Terraform workspaces using Terraform code (IaC)."
}

variable "workspaces_factory_execution_mode" {
  description = "(Optional) Which execution mode to use for the `workspaces factory`. Using Terraform Cloud, valid values are `remote`, `local` or `agent`. When set to `local`, the workspace will be used for state storage only. Important: If you omit this attribute, the resource configures the workspace to use your organization's default execution mode (which in turn defaults to `remote`), removing any explicit value that might have previously been set for the workspace."
  type        = string
  nullable    = true
  default     = null

  validation {
    condition     = var.workspaces_factory_execution_mode != null ? contains(["null", "remote", "local", "agent"], var.workspaces_factory_execution_mode) ? true : false : true
    error_message = "Valid values are \"remote\", \"local\" or \"agent\"."
  }
}

variable "workspaces_factory_branch_policies" {
  description = "(Optional) Branch policy configurations for the `workspaces factory` Azure DevOps repository. See the `azuredevops_repository` module `branch_policies` variable for the full schema."
  type = list(object({
    branch_ref                 = string
    match_type                 = optional(string, "Exact")
    enabled                    = optional(bool, true)
    blocking                   = optional(bool, true)
    require_comment_resolution = optional(bool, false)
    min_reviewers = optional(object({
      reviewer_count                         = number
      submitter_can_vote                     = optional(bool, false)
      last_pusher_cannot_approve             = optional(bool, true)
      allow_completion_with_rejects_or_waits = optional(bool, false)
      on_push_reset_approved_votes           = optional(bool, true)
      on_push_reset_all_votes                = optional(bool, false)
    }), null)
    merge_types = optional(object({
      allow_squash                  = optional(bool, true)
      allow_rebase_and_fast_forward = optional(bool, false)
      allow_basic_no_fast_forward   = optional(bool, true)
      allow_rebase_with_merge       = optional(bool, false)
    }), null)
    auto_reviewers = optional(object({
      reviewer_ids       = list(string)
      submitter_can_vote = optional(bool, false)
      message            = optional(string, null)
      path_filters       = optional(list(string), [])
    }), null)
  }))
  nullable = false
  default = [
    {
      branch_ref                 = "refs/heads/main"
      require_comment_resolution = true
      min_reviewers = {
        reviewer_count = 1
      }
      merge_types = {
        allow_squash            = true
        allow_basic_no_fast_forward = true
      }
    }
  ]
}

variable "workspaces_factory_tag" {
  description = "(Optional) A map of key value tags for this workspace for the `workspaces factory`."
  type        = map(string)
  nullable    = true
  default     = null
}

# *********************************************************************************************** #
#                                     Repositories Factory                                        #
# *********************************************************************************************** #

variable "repositories_factory_workspace_name" {
  description = "(Optional) Name of the workspace for the `repositories factory`."
  type        = string
  nullable    = true
  default     = "AzureDevOps-RepositoriesFactory"
}

variable "repositories_factory_agent_pool_id" {
  description = "(Optional) The ID of an agent pool to assign to the workspace for the `repositories factory`. Requires `execution_mode` to be set to `agent`. This value must not be provided if `execution_mode` is set to any other value."
  type        = string
  nullable    = true
  default     = null
}

variable "repositories_factory_description" {
  description = "(Optional) A description for the workspace for the `repositories factory`."
  type        = string
  nullable    = true
  default     = "Code to provision and manage Azure DevOps repositories using Terraform code (IaC)."
}

variable "repositories_factory_execution_mode" {
  description = "(Optional) Which execution mode to use for the `repositories factory`. Using Terraform Cloud, valid values are `remote`, `local` or `agent`. When set to `local`, the workspace will be used for state storage only. Important: If you omit this attribute, the resource configures the workspace to use your organization's default execution mode (which in turn defaults to `remote`), removing any explicit value that might have previously been set for the workspace."
  type        = string
  nullable    = true
  default     = null

  validation {
    condition     = var.repositories_factory_execution_mode != null ? contains(["null", "remote", "local", "agent"], var.repositories_factory_execution_mode) ? true : false : true
    error_message = "Valid values are \"remote\", \"local\" or \"agent\"."
  }
}

variable "repositories_factory_branch_policies" {
  description = "(Optional) Branch policy configurations for the `repositories factory` Azure DevOps repository. See the `azuredevops_repository` module `branch_policies` variable for the full schema."
  type = list(object({
    branch_ref                 = string
    match_type                 = optional(string, "Exact")
    enabled                    = optional(bool, true)
    blocking                   = optional(bool, true)
    require_comment_resolution = optional(bool, false)
    min_reviewers = optional(object({
      reviewer_count                         = number
      submitter_can_vote                     = optional(bool, false)
      last_pusher_cannot_approve             = optional(bool, true)
      allow_completion_with_rejects_or_waits = optional(bool, false)
      on_push_reset_approved_votes           = optional(bool, true)
      on_push_reset_all_votes                = optional(bool, false)
    }), null)
    merge_types = optional(object({
      allow_squash                  = optional(bool, true)
      allow_rebase_and_fast_forward = optional(bool, false)
      allow_basic_no_fast_forward   = optional(bool, true)
      allow_rebase_with_merge       = optional(bool, false)
    }), null)
    auto_reviewers = optional(object({
      reviewer_ids       = list(string)
      submitter_can_vote = optional(bool, false)
      message            = optional(string, null)
      path_filters       = optional(list(string), [])
    }), null)
  }))
  nullable = false
  default = [
    {
      branch_ref                 = "refs/heads/main"
      require_comment_resolution = true
      min_reviewers = {
        reviewer_count = 1
      }
      merge_types = {
        allow_squash            = true
        allow_basic_no_fast_forward = true
      }
    }
  ]
}

variable "repositories_factory_tag" {
  description = "(Optional) A map of key value tags for this workspace for the `repositories factory`."
  type        = map(string)
  nullable    = true
  default     = null
}

# *********************************************************************************************** #
#                                        Azure DevOps                                             #
# *********************************************************************************************** #

variable "azuredevops_organization" {
  description = "(Required) The name of the Azure DevOps organization (the segment after `dev.azure.com/` in the URL). Used to build the VCS identifier for HCP Terraform workspaces."
  type        = string
  nullable    = false
}

variable "azuredevops_project_name" {
  description = "(Required) The name of the Azure DevOps project in which all factory repositories will be created. Used to look up the project UUID at plan time."
  type        = string
  nullable    = false
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
