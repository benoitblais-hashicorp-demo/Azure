# The following code block is used to create and manage the project where all the workspaces related to the projects factory will be stored.

resource "tfe_project" "this" {
  name         = var.project_name
  organization = var.organization_name
  description  = var.project_description
  tags = merge(var.project_tags, {
    managed_by_terraform = "true"
  })
}

# The following module blocks are used to create and manage the HCP Terraform teams required by the projects factory.

module "team_write" {
  source         = "./modules/tfe_team"
  count          = var.sso_write_team_id != null ? 1 : 0
  name           = lower(replace("${tfe_project.this.name}-write", "/\\W|_|\\s/", "-"))
  organization   = var.organization_name
  project_access = "write"
  project_id     = tfe_project.this.id
  project_name   = tfe_project.this.name
  sso_team_id    = var.sso_write_team_id
}

module "team_read" {
  source         = "./modules/tfe_team"
  count          = var.sso_read_team_id != null ? 1 : 0
  name           = lower(replace("${tfe_project.this.name}-read", "/\\W|_|\\s/", "-"))
  organization   = var.organization_name
  project_access = "read"
  project_id     = tfe_project.this.id
  project_name   = tfe_project.this.name
  sso_team_id    = var.sso_read_team_id
}

# The following code block is used to create and manage the variable set at the project level that will own the variables required by the child workspaces.

resource "tfe_variable_set" "this" {
  name              = lower(replace("${tfe_project.this.name}-hcp", "/\\W|_|\\s/", "-"))
  description       = "Variable set for project \"${tfe_project.this.name}\"."
  organization      = var.organization_name
  parent_project_id = tfe_project.this.id
}

# Applies the variable set to all workspaces in the project ("Apply to the entire project").
# parent_project_id above makes the project own the variable set; this resource is what
# actually enables it across all current and future workspaces in the project.

resource "tfe_project_variable_set" "this" {
  project_id      = tfe_project.this.id
  variable_set_id = tfe_variable_set.this.id
}

# The following code block is used to create and manage the variables within the variable set at the project level.

resource "tfe_variable" "this" {
  for_each        = { for variable in var.variable_set_variables : variable.key => variable }
  key             = each.value.key
  value           = each.value.value
  category        = each.value.category
  description     = lookup(each.value, "description", null)
  hcl             = lookup(each.value, "hcl", false)
  sensitive       = lookup(each.value, "sensitive", false)
  variable_set_id = tfe_variable_set.this.id
}
