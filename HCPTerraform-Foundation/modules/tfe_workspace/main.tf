resource "tfe_workspace" "this" {

  name                          = var.name
  allow_destroy_plan            = var.allow_destroy_plan
  assessments_enabled           = var.assessments_enabled
  auto_apply                    = var.auto_apply
  auto_apply_run_trigger        = var.auto_apply_run_trigger
  description                   = var.description
  file_triggers_enabled         = var.file_triggers_enabled
  organization                  = var.organization
  project_id                    = var.project_id
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
    for_each = var.vcs_repo != null ? [true] : []
    content {
      identifier                 = var.vcs_repo.identifier
      branch                     = var.vcs_repo.branch
      ingress_submodules         = var.vcs_repo.ingress_submodules
      oauth_token_id             = var.vcs_repo.oauth_token_id
      github_app_installation_id = var.vcs_repo.github_app_installation_id
      tags_regex                 = var.vcs_repo.tags_regex
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

resource "tfe_workspace_run_task" "this" {
  for_each          = var.run_tasks != null ? { for value in var.run_tasks : value.task_id => value } : {}
  enforcement_level = each.value.enforcement_level
  task_id           = each.value.task_id
  workspace_id      = tfe_workspace.this.id
  stages            = each.value.stages
}