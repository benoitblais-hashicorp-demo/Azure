# The following locals block constructs derived values used throughout this configuration.

locals {
  azdo_org_service_url = "${var.azuredevops_service_url}/${var.azuredevops_organization}"

  # identifier: URL-encoded form required by the HCP Terraform API when creating/updating
  # the registry module VCS connection.
  # Format: <org>/<project%20encoded>/_git/<repo>
  vcs_identifier = length(module.modules_factory_repository) > 0 ? "${var.azuredevops_organization}/${replace(var.azuredevops_project_name, " ", "%20")}/_git/${module.modules_factory_repository[0].repository.name}" : null

  # display_identifier: unencoded form returned by the HCP Terraform API on read-back.
  # Format: <org>/<project with spaces>/_git/<repo>
  # Must include /_git/ to match what the API returns, otherwise every plan shows a diff.
  vcs_display_identifier = length(module.modules_factory_repository) > 0 ? "${var.azuredevops_organization}/${var.azuredevops_project_name}/_git/${module.modules_factory_repository[0].repository.name}" : null
}

# The following data source looks up the Azure DevOps project by name to obtain its UUID,
# which is required by all azuredevops_* resources.

data "azuredevops_project" "this" {
  name = var.azuredevops_project_name
}

# The following code block is used to create and manage the project where all the workspaces related to the published modules will be stored.

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

# The following resource blocks are used to create variables that will be stored into the variable set previously created.

resource "tfe_variable" "azdo_org_service_url" {
  count           = length(tfe_variable_set.this) > 0 ? 1 : 0
  key             = "AZDO_ORG_SERVICE_URL"
  value           = local.azdo_org_service_url
  category        = "env"
  sensitive       = false
  variable_set_id = tfe_variable_set.this[0].id
}

resource "tfe_variable" "azdo_personal_access_token" {
  count           = length(tfe_variable_set.this) > 0 ? 1 : 0
  key             = "AZDO_PERSONAL_ACCESS_TOKEN"
  value           = var.azuredevops_personal_access_token
  category        = "env"
  sensitive       = true
  variable_set_id = tfe_variable_set.this[0].id
}

resource "tfe_variable" "azuredevops_project_name" {
  count           = length(tfe_variable_set.this) > 0 ? 1 : 0
  key             = "azuredevops_project_name"
  value           = var.azuredevops_project_name
  category        = "terraform"
  description     = "(Required) Name of the Azure DevOps project where repositories will be created."
  sensitive       = false
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

resource "tfe_variable" "oauth_client_name" {
  count           = length(tfe_variable_set.this) > 0 ? 1 : 0
  key             = "oauth_client_name"
  value           = var.oauth_client_name
  category        = "terraform"
  description     = "(Optional) Name of the OAuth client."
  sensitive       = false
  variable_set_id = tfe_variable_set.this[0].id
}

resource "tfe_variable" "organization_name" {
  count           = length(tfe_variable_set.this) > 0 ? 1 : 0
  key             = "organization_name"
  value           = var.organization_name
  category        = "terraform"
  description     = "(Required) Name of the organization."
  sensitive       = false
  variable_set_id = tfe_variable_set.this[0].id
}

resource "tfe_variable" "tfe_token" {
  count           = length(tfe_variable_set.this) > 0 ? 1 : 0
  key             = "TFE_TOKEN"
  value           = var.tfe_token
  category        = "env"
  sensitive       = true
  variable_set_id = tfe_variable_set.this[0].id
}

# The following resource blocks create Azure DevOps variable groups that are referenced by name
# in the pipeline YAML files (merge-pipeline.yml, tag-pipeline.yml, release-pipeline.yml).
# Because variable groups are project-scoped, every pipeline in the same project —
# including those in repositories created by the no-code module — can reference them by name.

resource "azuredevops_variable_group" "hcp_terraform" {
  count        = length(tfe_project.this) > 0 ? 1 : 0
  project_id   = data.azuredevops_project.this.id
  name         = "hcp-terraform"
  description  = "HCP Terraform credentials used by tag-pipeline.yml and release-pipeline.yml."
  allow_access = true

  variable {
    name  = "TFC_ORGANIZATION"
    value = var.organization_name
  }

  variable {
    name         = "TFE_TOKEN"
    secret_value = var.tfe_token
    is_secret    = true
  }
}

resource "azuredevops_variable_group" "azure_devops" {
  count        = length(tfe_project.this) > 0 ? 1 : 0
  project_id   = data.azuredevops_project.this.id
  name         = "azure-devops"
  description  = "Azure DevOps credentials used by merge-pipeline.yml to push semver tags."
  allow_access = true

  variable {
    name         = "AZDO_PAT"
    secret_value = var.azuredevops_personal_access_token
    is_secret    = true
  }
}

# The following module block is used to create and manage the Azure DevOps repository that will contain the Terraform module used by the factory.

module "modules_factory_repository" {
  source     = "./modules/azuredevops_repository"
  count      = length(tfe_project.this) > 0 ? 1 : 0
  name       = var.module_name
  project_id = data.azuredevops_project.this.id
}

# The following code block is used to create module resources in the private registry.

resource "tfe_registry_module" "this" {
  count           = length(module.modules_factory_repository) > 0 ? 1 : 0
  organization    = var.organization_name
  initial_version = "0.0.0"
  test_config {
    tests_enabled = true
  }
  vcs_repo {
    display_identifier = local.vcs_display_identifier
    identifier         = local.vcs_identifier
    oauth_token_id     = var.vcs_oauth_token_id
    branch             = "main"
  }

  # display_identifier is ignored after initial creation because the HCP Terraform API
  # returns a normalised form (without /_git/) on read-back regardless of what was written,
  # causing a perpetual diff on every plan. The identifier and branch are what matter for
  # the VCS connection — display_identifier is cosmetic only.
  lifecycle {
    ignore_changes = [vcs_repo[0].display_identifier]
  }
}

resource "tfe_no_code_module" "this" {
  count           = length(tfe_registry_module.this) > 0 ? 1 : 0
  organization    = var.organization_name
  registry_module = tfe_registry_module.this[0].id
}

resource "tfe_test_variable" "azdo_org_service_url" {
  count           = length(tfe_registry_module.this) > 0 ? 1 : 0
  key             = "AZDO_ORG_SERVICE_URL"
  value           = local.azdo_org_service_url
  category        = "env"
  module_name     = tfe_registry_module.this[0].name
  module_provider = tfe_registry_module.this[0].module_provider
  organization    = var.organization_name
  sensitive       = false
}

resource "tfe_test_variable" "azdo_personal_access_token" {
  count           = length(tfe_registry_module.this) > 0 ? 1 : 0
  key             = "AZDO_PERSONAL_ACCESS_TOKEN"
  value           = var.azuredevops_personal_access_token
  category        = "env"
  module_name     = tfe_registry_module.this[0].name
  module_provider = tfe_registry_module.this[0].module_provider
  organization    = var.organization_name
  sensitive       = true
}

resource "tfe_test_variable" "azdo_organization" {
  count           = length(tfe_registry_module.this) > 0 ? 1 : 0
  key             = "TF_VAR_azuredevops_organization"
  value           = var.azuredevops_organization
  category        = "env"
  module_name     = tfe_registry_module.this[0].name
  module_provider = tfe_registry_module.this[0].module_provider
  organization    = var.organization_name
  sensitive       = false
}

resource "tfe_test_variable" "azuredevops_project_name" {
  count           = length(tfe_registry_module.this) > 0 ? 1 : 0
  key             = "TF_VAR_azuredevops_project_name"
  value           = var.azuredevops_project_name
  category        = "env"
  module_name     = tfe_registry_module.this[0].name
  module_provider = tfe_registry_module.this[0].module_provider
  organization    = var.organization_name
  sensitive       = false
}

resource "tfe_test_variable" "azdo_personal_access_token_var" {
  count           = length(tfe_registry_module.this) > 0 ? 1 : 0
  key             = "TF_VAR_azuredevops_personal_access_token"
  value           = var.azuredevops_personal_access_token
  category        = "env"
  module_name     = tfe_registry_module.this[0].name
  module_provider = tfe_registry_module.this[0].module_provider
  organization    = var.organization_name
  sensitive       = true
}

resource "tfe_test_variable" "oauth_client_name" {
  count           = length(tfe_registry_module.this) > 0 ? 1 : 0
  key             = "TF_VAR_oauth_client_name"
  value           = var.oauth_client_name
  category        = "env"
  module_name     = tfe_registry_module.this[0].name
  module_provider = tfe_registry_module.this[0].module_provider
  organization    = var.organization_name
  sensitive       = false
}

resource "tfe_test_variable" "organization_name" {
  count           = length(tfe_registry_module.this) > 0 ? 1 : 0
  key             = "TF_VAR_organization_name"
  value           = var.organization_name
  category        = "env"
  module_name     = tfe_registry_module.this[0].name
  module_provider = tfe_registry_module.this[0].module_provider
  organization    = var.organization_name
  sensitive       = false
}

resource "tfe_test_variable" "tfe_token" {
  count           = length(tfe_registry_module.this) > 0 ? 1 : 0
  key             = "TFE_TOKEN"
  value           = var.tfe_token
  category        = "env"
  module_name     = tfe_registry_module.this[0].name
  module_provider = tfe_registry_module.this[0].module_provider
  organization    = var.organization_name
  sensitive       = true
}
