# The following code block is used to create and manage the project where all the workspaces related to the workspaces factory will be stored.

resource "tfe_project" "this" {
  count        = var.project_name != null ? 1 : 0
  name         = var.project_name
  organization = var.organization_name
  description  = var.project_description
  tags = merge(var.project_tags, {
    managed_by_terraform = "true"
  })
}

# The following code block is used to create and manage the variable set at the project level that will own the variables required by the child workspaces.

resource "tfe_variable_set" "this" {
  count             = length(tfe_project.this) > 0 ? 1 : 0
  name              = lower(replace("${tfe_project.this[0].name}-hcp", "/\\W|_|\\s/", "-"))
  description       = "Variable set for project \"${tfe_project.this[0].name}\"."
  organization      = var.organization_name
  parent_project_id = tfe_project.this[0].id
}

# Applies the variable set to all workspaces in the project ("Apply to the entire project").
# parent_project_id above makes the project own the variable set; this resource is what
# actually enables it across all current and future workspaces in the project.

resource "tfe_project_variable_set" "this" {
  count           = length(tfe_variable_set.this) > 0 ? 1 : 0
  project_id      = tfe_project.this[0].id
  variable_set_id = tfe_variable_set.this[0].id
}

# The following module blocks are used to create and manage the HCP Terraform teams required by the workspaces factory.

module "workspaces_factory_team_hcp" {
  source       = "./modules/tfe_team"
  count        = length(tfe_project.this) > 0 ? 1 : 0
  name         = lower(replace("${tfe_project.this[0].name}-hcp", "/\\W|_|\\s/", "-"))
  organization = var.organization_name
  organization_access = {
    manage_membership          = true
    manage_organization_access = true
    manage_projects            = true
    manage_teams               = true
    manage_workspaces          = true
  }
  token = true
}

# The following resource blocks are used to create variables that will be stored into the variable set previously created.

resource "tfe_variable" "tfe_token" {
  count           = length(module.workspaces_factory_team_hcp) > 0 ? 1 : 0
  key             = "TFE_TOKEN"
  value           = module.workspaces_factory_team_hcp[0].token
  category        = "env"
  sensitive       = true
  variable_set_id = tfe_variable_set.this[0].id
}

resource "tfe_variable" "azuredevops_organization" {
  count           = length(tfe_variable_set.this) > 0 ? 1 : 0
  key             = "azuredevops_organization"
  value           = var.azuredevops_organization
  category        = "terraform"
  description     = "(Required) The name of the Azure DevOps organization."
  sensitive       = false
  variable_set_id = tfe_variable_set.this[0].id
}

resource "tfe_variable" "azuredevops_project_name" {
  count           = length(tfe_variable_set.this) > 0 ? 1 : 0
  key             = "azuredevops_project_name"
  value           = var.azuredevops_project_name
  category        = "terraform"
  description     = "(Required) The name of the Azure DevOps project."
  sensitive       = false
  variable_set_id = tfe_variable_set.this[0].id
}

resource "tfe_variable" "organization_name" {
  count           = length(tfe_variable_set.this) > 0 ? 1 : 0
  key             = "organization_name"
  value           = var.organization_name
  category        = "terraform"
  description     = "(Required) Name of the HCP Terraform organization."
  sensitive       = false
  variable_set_id = tfe_variable_set.this[0].id
}

resource "tfe_variable" "vcs_repo_oauth_token_id" {
  count           = length(tfe_variable_set.this) > 0 ? 1 : 0
  key             = "vcs_repo_oauth_token_id"
  value           = var.vcs_oauth_token_id
  category        = "terraform"
  description     = "(Required) The OAuth Token ID of the HCP Terraform VCS Provider connection."
  sensitive       = false
  variable_set_id = tfe_variable_set.this[0].id
}
