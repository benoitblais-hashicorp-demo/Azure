resource "tfe_team" "this" {

  name         = var.name
  sso_team_id  = var.sso_team_id
  organization = var.organization

  dynamic "organization_access" {
    for_each = var.organization_access != null ? [true] : []
    content {
      access_secret_teams        = var.organization_access.access_secret_teams
      manage_agent_pools         = var.organization_access.manage_agent_pools
      manage_membership          = var.organization_access.manage_membership
      manage_modules             = var.organization_access.manage_modules
      manage_organization_access = var.organization_access.manage_organization_access
      manage_policies            = var.organization_access.manage_policies
      manage_policy_overrides    = var.organization_access.manage_policy_overrides
      manage_projects            = var.organization_access.manage_projects
      manage_providers           = var.organization_access.manage_providers
      manage_run_tasks           = var.organization_access.manage_run_tasks
      manage_teams               = var.organization_access.manage_teams
      manage_vcs_settings        = var.organization_access.manage_vcs_settings
      manage_workspaces          = var.organization_access.manage_workspaces
      read_projects              = var.organization_access.read_projects
      read_workspaces            = var.organization_access.read_workspaces
    }
  }

  visibility = var.visibility

}

resource "time_rotating" "token_expiry" {
  count            = var.token ? 1 : 0
  rotation_months  = 24
}

resource "tfe_team_token" "this" {

  count = var.token ? 1 : 0

  team_id          = tfe_team.this.id
  description      = var.token_description
  expired_at       = time_rotating.token_expiry[0].rotation_rfc3339
  force_regenerate = var.token_force_regenerate

}

resource "tfe_team_organization_members" "this" {

  count = length(var.organization_membership_ids) > 0 ? 1 : 0

  team_id                     = tfe_team.this.id
  organization_membership_ids = var.organization_membership_ids

}

resource "tfe_team_project_access" "this" {

  count = var.project_name != null ? 1 : 0

  access = var.project_access

  dynamic "project_access" {
    for_each = var.custom_project_access != null ? [true] : []
    content {
      settings = var.custom_project_access.settings
      teams    = var.custom_project_access.teams
    }
  }

  project_id = var.project_id
  team_id    = tfe_team.this.id

  dynamic "workspace_access" {
    for_each = var.custom_workspace_access != null ? [true] : []
    content {
      create         = var.custom_workspace_access.create
      delete         = var.custom_workspace_access.delete
      locking        = var.custom_workspace_access.locking
      move           = var.custom_workspace_access.move
      runs           = var.custom_workspace_access.runs
      run_tasks      = var.custom_workspace_access.run_tasks
      sentinel_mocks = var.custom_workspace_access.sentinel_mocks
      state_versions = var.custom_workspace_access.state_versions
      variables      = var.custom_workspace_access.variables
    }
  }

}

resource "tfe_team_access" "this" {

  count = var.workspace_access != null || var.workspace_permission != null ? 1 : 0

  access = var.workspace_access

  dynamic "permissions" {
    for_each = var.workspace_permission != null ? [true] : []
    content {
      runs              = var.workspace_permission.runs
      run_tasks         = var.workspace_permission.run_tasks
      sentinel_mocks    = var.workspace_permission.sentinel_mocks
      state_versions    = var.workspace_permission.state_versions
      variables         = var.workspace_permission.variables
      workspace_locking = var.workspace_permission.workspace_locking
    }
  }

  team_id      = tfe_team.this.id
  workspace_id = var.workspace_id

  lifecycle {
    precondition {
      condition     = var.workspace_permission != null ? var.workspace_access != null ? false : true : true
      error_message = "`workspace_permission` value must not be provided if access is provided."
    }
  }
}