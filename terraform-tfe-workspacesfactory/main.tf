# The following locals block constructs the VCS identifier required by HCP Terraform.
# In Azure DevOps, spaces in the project name must be URL-encoded (%20) in the identifier.
# When vcs_repo_identifier is provided it takes precedence over the automatically built value.

locals {
  # identifier: URL-encoded form required by the HCP Terraform API.
  # Format: <azdo_org>/<project%20name>/_git/<repo>
  vcs_identifier = var.vcs_repo_identifier != null ? var.vcs_repo_identifier : (
    var.azuredevops_organization != null && var.azuredevops_project_name != null && var.vcs_repo_name != null
    ? "${var.azuredevops_organization}/${replace(var.azuredevops_project_name, " ", "%20")}/_git/${var.vcs_repo_name}"
    : null
  )
}

# The following data source is used to look up the project by name to resolve its ID.

data "tfe_project" "this" {
  count        = var.project_name != null ? 1 : 0
  organization = var.organization_name
  name         = var.project_name
}

# The following code block is used to create and manage the HCP Terraform workspace.

resource "tfe_workspace" "this" {

  name                          = lower(var.name)
  allow_destroy_plan            = var.allow_destroy_plan
  assessments_enabled           = var.assessments_enabled
  auto_apply                    = var.auto_apply
  auto_apply_run_trigger        = var.auto_apply_run_trigger
  description                   = var.description
  file_triggers_enabled         = var.file_triggers_enabled
  organization                  = var.organization_name
  project_id                    = length(data.tfe_project.this) > 0 ? data.tfe_project.this[0].id : null
  queue_all_runs                = var.queue_all_runs
  source_name                   = var.source_name
  source_url                    = var.source_url
  speculative_enabled           = var.speculative_enabled
  ssh_key_id                    = var.ssh_key_id
  structured_run_output_enabled = var.structured_run_output_enabled
  tags                          = var.tags
  terraform_version             = var.terraform_version
  trigger_patterns              = var.trigger_patterns
  trigger_prefixes              = var.trigger_prefixes

  dynamic "vcs_repo" {
    for_each = local.vcs_identifier != null ? [true] : []
    content {
      identifier                 = local.vcs_identifier
      branch                     = var.vcs_repo_branch
      ingress_submodules         = var.vcs_repo_ingress_submodules
      oauth_token_id             = var.vcs_repo_oauth_token_id
      github_app_installation_id = var.vcs_repo_github_app_installation_id
      tags_regex                 = var.vcs_repo_tags_regex
    }
  }

  working_directory = var.working_directory

  lifecycle {
    ignore_changes = [source_url]

    precondition {
      condition     = var.source_url != null ? var.source_name != null : true
      error_message = "`source_url` requires `source_name` to also be set."
    }
  }

}

# The following code block is used to manage the execution settings for the workspace.

resource "tfe_workspace_settings" "this" {

  count                     = var.execution_mode != null ? 1 : 0
  workspace_id              = tfe_workspace.this.id
  agent_pool_id             = var.agent_pool_id
  execution_mode            = var.execution_mode
  global_remote_state       = var.global_remote_state
  remote_state_consumer_ids = var.remote_state_consumer_ids

  lifecycle {
    precondition {
      condition     = var.agent_pool_id != null ? var.execution_mode == "agent" : true
      error_message = "`agent_pool_id` requires `execution_mode` to be set to `agent`."
    }
  }

}

# The following code block is used to create and manage the run tasks for the workspace.

resource "tfe_workspace_run_task" "this" {
  for_each          = var.run_tasks != null ? { for value in var.run_tasks : value.task_id => value } : {}
  enforcement_level = each.value.enforcement_level
  task_id           = each.value.task_id
  workspace_id      = tfe_workspace.this.id
  stages            = each.value.stages
}

# The following code block is used to create and manage the variables for the workspace.

resource "tfe_variable" "this" {
  for_each     = { for variable in var.variables : variable.key => variable }
  key          = each.value.key
  value        = each.value.value
  category     = each.value.category
  description  = lookup(each.value, "description", null)
  hcl          = lookup(each.value, "hcl", false)
  sensitive    = lookup(each.value, "sensitive", false)
  workspace_id = tfe_workspace.this.id
}
