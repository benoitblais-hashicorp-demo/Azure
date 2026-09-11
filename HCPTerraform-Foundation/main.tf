# The following code manage the organization settins.

resource "tfe_organization" "this" {
  email                                                   = var.organization_email
  name                                                    = var.organization_name
  aggregated_commit_status_enabled                        = var.aggregated_commit_status_enabled
  allow_force_delete_workspaces                           = var.allow_force_delete_workspaces
  assessments_enforced                                    = var.assessments_enforced
  collaborator_auth_policy                                = var.collaborator_auth_policy
  cost_estimation_enabled                                 = var.cost_estimation_enabled
  owners_team_saml_role_id                                = var.owners_team_saml_role_id
  send_passing_statuses_for_untriggered_speculative_plans = var.send_passing_statuses_for_untriggered_speculative_plans
  session_remember_minutes                                = var.session_remember_minutes
  session_timeout_minutes                                 = var.session_timeout_minutes
  speculative_plan_management_enabled                     = var.speculative_plan_management_enabled
  stacks_enabled                                          = var.stacks_enabled
  user_tokens_enabled                                     = var.user_tokens_enabled
}

# The following code block must be use to import de organization into terraform.  Once it's done, you can remove it.

# import {
#   id = "benoitblais-azuredevops"
#   to = tfe_organization.this
# }

# The following code block is use to set the default execution mode of an organization. 

resource "tfe_organization_default_settings" "this" {
  # default_agent_pool_id  = var.default_agent_pool_id
  default_execution_mode = var.default_execution_mode
  organization           = tfe_organization.this.name

  # lifecycle {
  #   precondition {
  #     condition     = var.default_agent_pool_id != null ? var.default_execution_mode == "agent" ? true : false : true
  #     error_message = "Requires `default_execution_mode` to be set to \"agent\" if `default_agent_pool_id` is set."
  #   }
  # }
}

# The following code block is use to create and manage agent pools avaiable at the organization level.

# -----------------------------------------------------------------------
# HOW TO IMPORT AN EXISTING AGENT POOL
# -----------------------------------------------------------------------
# Each entry in var.agent_pools maps to one module instance keyed by the
# pool name (the for_each key). You need one import block per pool.
#
# Step 1 – Find the agent pool ID.
#   In HCP Terraform: Organization Settings → Agents → click the pool →
#   the ID ("apool-XXXXXXXXXXXXXXXX") is visible in the browser URL bar,
#   e.g.: https://app.terraform.io/app/<org>/settings/agents/apool-XXXXXXXXXXXXXXXX
#   Alternatively, run:
#     curl -s -H "Authorization: Bearer $TFE_TOKEN" \
#          https://app.terraform.io/api/v2/organizations/<org>/agent-pools \
#       | jq '.data[] | {name: .attributes.name, id: .id}'
#
# Step 2 – Find the agent token ID (one per description in token_description).
#   In HCP Terraform: inside the agent pool page, each token lists its ID
#   ("at-XXXXXXXXXXXXXXXX") under "Agent Tokens".
#   Alternatively, run:
#     curl -s -H "Authorization: Bearer $TFE_TOKEN" \
#          https://app.terraform.io/api/v2/agent-pools/<POOL_ID>/authentication-tokens \
#       | jq '.data[] | {description: .attributes.description, id: .id}'
#
# Step 3 – Uncomment and fill in ONE block per pool (and one per token).
#   The for_each key is the pool name as it appears in var.agent_pools.
#
# import {
#   to = module.agent_pool["<POOL_NAME>"].tfe_agent_pool.this
#   id = "<POOL_ID>"                     # e.g. apool-XXXXXXXXXXXXXXXX
#                                        # or   <ORG_NAME>/<POOL_NAME>
# }
#
# import {
#   to = module.agent_pool["<POOL_NAME>"].tfe_agent_token.this["token"]
#   id = "<AGENT_TOKEN_ID>"              # e.g. at-XXXXXXXXXXXXXXXX
# }
# -----------------------------------------------------------------------

module "agent_pool" {
  source              = "./modules/tfe_agent"
  for_each            = toset(var.agent_pools)
  name                = each.value
  organization        = tfe_organization.this.name
  organization_scoped = true
  token_description   = ["token"]
}

# The following code block is use to create and manage team at the organization level.

# -----------------------------------------------------------------------
# HOW TO IMPORT AN EXISTING TEAM
# -----------------------------------------------------------------------
# Each entry in var.teams maps to one module instance keyed by the team
# name (the for_each key). You need one import block per team, and one
# additional block if the team has a token (token = true in var.teams).
#
# Step 1 – Find the team ID.
#   In HCP Terraform: Organization Settings → Teams → click the team →
#   the ID ("team-XXXXXXXXXXXXXXXX") appears in the browser URL bar,
#   e.g.: https://app.terraform.io/app/<org>/settings/teams/team-XXXXXXXXXXXXXXXX
#   Alternatively, run:
#     curl -s -H "Authorization: Bearer $TFE_TOKEN" \
#          https://app.terraform.io/api/v2/organizations/<org>/teams \
#       | jq '.data[] | {name: .attributes.name, id: .id}'
#
# Step 2 – Find the team token ID (only needed when token = true).
#   In HCP Terraform: inside the team page, under "Team API Token", the
#   token ID ("at-XXXXXXXXXXXXXXXX") is shown next to each token entry.
#   Alternatively, run:
#     curl -s -H "Authorization: Bearer $TFE_TOKEN" \
#          https://app.terraform.io/api/v2/teams/<TEAM_ID>/authentication-tokens \
#       | jq '.data[] | {description: .attributes.description, id: .id}'
#
# Step 3 – Uncomment and fill in ONE block per team (and one per token).
#   The for_each key is the team name as it appears in var.teams[*].name.
#
# import {
#   to = module.teams["<TEAM_NAME>"].tfe_team.this
#   id = "<TEAM_ID>"                     # e.g. team-XXXXXXXXXXXXXXXX
#                                        # or   <ORG_NAME>/<TEAM_NAME>
# }
#
# import {
#   to = module.teams["<TEAM_NAME>"].tfe_team_token.this[0]
#   id = "<TEAM_TOKEN_ID>"               # e.g. at-XXXXXXXXXXXXXXXX
#                                        # or   <TEAM_ID>
# }
# -----------------------------------------------------------------------

module "teams" {
  source                 = "./modules/tfe_team"
  for_each               = nonsensitive({ for team in var.teams : team.name => team })
  name                   = each.value.name
  organization           = tfe_organization.this.name
  organization_access    = try(each.value.organization_access, null)
  sso_team_id            = try(each.value.sso_team_id, null)
  token                  = try(each.value.token, false)
  token_force_regenerate = try(each.value.token_force_regenerate, null)
  visibility             = try(each.value.visibility, "organization")
}

# The following code block is use to create and manage the project where all the workspaces related to the foundation will be stored.

resource "tfe_project" "hcp_foundation" {
  count        = var.hcp_foundation_project_name != null ? 1 : 0
  name         = var.hcp_foundation_project_name
  organization = tfe_organization.this.name
  description  = var.hcp_foundation_project_description
  tags = merge(var.hcp_foundation_project_tags, {
    managed_by_terraform = "true"
  })
}

# The following data source looks up the Azure DevOps project by name to obtain its UUID,
# which is required by all azuredevops_* resources.

data "azuredevops_project" "this" {
  name = var.azuredevops_project_name
}

# *********************************************************************************************** #
#                                       Policies Factory                                          #
# *********************************************************************************************** #

# The following module block is used to create and manage the workspace used by the `policies factory`.

# -----------------------------------------------------------------------
# HOW TO IMPORT THE POLICIES FACTORY WORKSPACE
# -----------------------------------------------------------------------
# The workspace already exists and is configured as a VCS-driven workspace
# pointing to the Azure DevOps repository.
#
# Step 1 – Find the workspace ID.
#   In HCP Terraform: navigate to the workspace → Settings → General →
#   the ID ("ws-XXXXXXXXXXXXXXXX") is shown at the bottom of the page.
#   Alternatively, run:
#     curl -s -H "Authorization: Bearer $TFE_TOKEN" \
#          "https://app.terraform.io/api/v2/organizations/<org>/workspaces?search[name]=<workspace_name>" \
#       | jq '.data[] | {name: .attributes.name, id: .id}'
#
# Step 2 – Uncomment the block below, fill in the workspace ID, then run
#   `terraform plan` (Terraform will show what it will bring under management)
#   followed by `terraform apply` to complete the import.
#   Once the import is done, remove the import block.
#
# import {
#   to = module.policies_factory_workspace[0].tfe_workspace.this
#   id = "<WORKSPACE_ID>"            # e.g. ws-XXXXXXXXXXXXXXXX
#                                    # or   <ORG_NAME>/<WORKSPACE_NAME>
# }
# -----------------------------------------------------------------------

module "policies_factory_workspace" {
  source         = "./modules/tfe_workspace"
  count          = var.policies_factory_workspace_name != null ? 1 : 0
  name           = lower(var.policies_factory_workspace_name)
  agent_pool_id  = var.policies_factory_agent_pool_id
  description    = var.policies_factory_description
  execution_mode = var.policies_factory_execution_mode
  organization   = tfe_organization.this.name
  project_id     = length(tfe_project.hcp_foundation) > 0 ? tfe_project.hcp_foundation[0].id : null
  tags           = merge(var.policies_factory_tag, { managed_by_terraform = true })

  vcs_repo = {
    # Azure DevOps VCS identifier format: <ado org>/<ado project>/_git/<ado repository>
    # Project name must be URL-encoded (spaces → %20) as required by the HCP Terraform provider.
    identifier     = "${var.azuredevops_organization}/${replace(var.azuredevops_project_name, " ", "%20")}/_git/${module.policies_factory_repository[0].repository.name}"
    branch         = "main"
    oauth_token_id = var.vcs_oauth_token_id
  }
}

# The following module block is used to create and manage the HCP Terraform team required by the `policies factory`.
# Note: the `-git` team has been removed because the workspace is VCS-driven via Azure DevOps
# and no longer requires an API-driven team token to trigger runs.

# -----------------------------------------------------------------------
# HOW TO IMPORT THE POLICIES FACTORY HCP TEAM
# -----------------------------------------------------------------------
# Step 1 – Find the team ID.
#   In HCP Terraform: Organization Settings → Teams → click the team →
#   the ID ("team-XXXXXXXXXXXXXXXX") is visible in the browser URL bar.
#   Alternatively, run:
#     curl -s -H "Authorization: Bearer $TFE_TOKEN" \
#          https://app.terraform.io/api/v2/organizations/<org>/teams \
#       | jq '.data[] | {name: .attributes.name, id: .id}'
#
# Step 2 – Find the team token ID.
#   In HCP Terraform: inside the team page, under "Team API Token", the
#   token ID ("at-XXXXXXXXXXXXXXXX") is listed next to each token entry.
#   Alternatively, run:
#     curl -s -H "Authorization: Bearer $TFE_TOKEN" \
#          https://app.terraform.io/api/v2/teams/<TEAM_ID>/authentication-tokens \
#       | jq '.data[] | {description: .attributes.description, id: .id}'
#
# Step 3 – Uncomment the blocks below, fill in the IDs, then run
#   `terraform plan` followed by `terraform apply`.
#   Once the import is done, remove the import blocks.
#
# import {
#   to = module.policies_factory_team_hcp[0].tfe_team.this
#   id = "<TEAM_ID>"                 # e.g. team-XXXXXXXXXXXXXXXX
#                                    # or   <ORG_NAME>/<TEAM_NAME>
# }
#
# import {
#   to = module.policies_factory_team_hcp[0].tfe_team_token.this[0]
#   id = "<TEAM_TOKEN_ID>"           # e.g. at-XXXXXXXXXXXXXXXX
#                                    # or   <TEAM_ID>
# }
# -----------------------------------------------------------------------

module "policies_factory_team_hcp" {
  source       = "./modules/tfe_team"
  count        = var.policies_factory_workspace_name != null ? 1 : 0
  name         = lower(replace("${module.policies_factory_workspace[0].workspace.name}-hcp", "/\\W|_|\\s/", "-"))
  organization = tfe_organization.this.name
  organization_access = {
    manage_policies = true
  }
  token = true
}

# The following resource block is used to create and manage the environment variable required at the workspace level to get authenticated into HCP Terraform by the workspace.

# -----------------------------------------------------------------------
# HOW TO IMPORT THE TFE_TOKEN WORKSPACE VARIABLE
# -----------------------------------------------------------------------
# Step 1 – Find the variable ID.
#   In HCP Terraform: navigate to the workspace → Variables → click the
#   variable → the ID ("var-XXXXXXXXXXXXXXXX") is shown in the URL bar.
#   Alternatively, run:
#     curl -s -H "Authorization: Bearer $TFE_TOKEN" \
#          "https://app.terraform.io/api/v2/workspaces/<WORKSPACE_ID>/vars" \
#       | jq '.data[] | {key: .attributes.key, id: .id}'
#
# Step 2 – Uncomment the block below, fill in the IDs, then run
#   `terraform plan` followed by `terraform apply`.
#   Once the import is done, remove the import block.
#   NOTE: Because the variable is sensitive, Terraform will show a diff
#   on the value after import — this is expected. The value will be
#   updated to match the token from module.policies_factory_team_hcp[0].
#
# import {
#   to = tfe_variable.policies_factory[0]
#   id = "<ORG_NAME>/<WORKSPACE_NAME>/var-XXXXXXXXXXXXXXXX"
# }
# -----------------------------------------------------------------------

resource "tfe_variable" "policies_factory" {
  count        = length(module.policies_factory_team_hcp) > 0 ? 1 : 0
  key          = "TFE_TOKEN"
  value        = module.policies_factory_team_hcp[0].token
  category     = "env"
  sensitive    = true
  workspace_id = module.policies_factory_workspace[0].id
}

# The following resource block is used to create and manage the terraform variable required at the workspace level.

resource "tfe_variable" "policies_factory_organization_name" {
  count        = length(module.policies_factory_team_hcp) > 0 ? 1 : 0
  key          = "organization_name"
  value        = var.organization_name
  category     = "terraform"
  description  = "(Required) Name of the organization."
  sensitive    = false
  workspace_id = module.policies_factory_workspace[0].id
}

# The following module block is used to create and manage the Azure DevOps repository used by the `policies factory`.

# -----------------------------------------------------------------------
# HOW TO IMPORT THE POLICIES FACTORY AZURE DEVOPS REPOSITORY
# -----------------------------------------------------------------------
# The repository already exists in Azure DevOps and the workspace is
# already configured to use it as its VCS source.
#
# Step 1 – Find the project name and repository name (or GUID).
#   In Azure DevOps: navigate to the repository → the URL contains both:
#   https://dev.azure.com/<org>/<project>/_git/<repository>
#   To get the repository GUID, run:
#     az repos show --org https://dev.azure.com/<org> \
#                   --project "<project>" \
#                   --repository "<repository_name>" \
#                   --query id -o tsv
#
# Step 2 – Uncomment the block below, fill in the IDs, then run
#   `terraform plan` followed by `terraform apply`.
#   Once the import is done, remove the import block.
#   NOTE: After importing, Terraform will detect a diff on the
#   `initialization` block — this is expected and suppressed by the
#   `lifecycle { ignore_changes = [initialization] }` rule in the module.
#
# import {
#   to = module.policies_factory_repository[0].azuredevops_git_repository.this
#   id = "<PROJECT_NAME>/<REPOSITORY_NAME>"   # e.g. MyProject/HCPTerraform-PoliciesFactory
#                                             # or   MyProject/<REPOSITORY_GUID>
# }
# -----------------------------------------------------------------------

module "policies_factory_repository" {
  source          = "./modules/azuredevops_repository"
  count           = var.policies_factory_workspace_name != null ? 1 : 0
  project_id      = data.azuredevops_project.this.id
  name            = var.policies_factory_workspace_name
  branch_policies = var.policies_factory_branch_policies
}

# *********************************************************************************************** #
#                                        Modules Factory                                          #
# *********************************************************************************************** #

# The following module block is used to create and manage the workspace used by the `modules factory`.

# -----------------------------------------------------------------------
# HOW TO IMPORT THE MODULES FACTORY WORKSPACE
# -----------------------------------------------------------------------
# Step 1 – Find the workspace ID.
#   In HCP Terraform: navigate to the workspace → Settings → General →
#   the ID ("ws-XXXXXXXXXXXXXXXX") is shown at the bottom of the page.
#   Alternatively, run:
#     curl -s -H "Authorization: Bearer $TFE_TOKEN" \
#          "https://app.terraform.io/api/v2/organizations/<org>/workspaces?search[name]=<workspace_name>" \
#       | jq '.data[] | {name: .attributes.name, id: .id}'
#
# Step 2 – Uncomment the block below, fill in the workspace ID, then run
#   `terraform plan` followed by `terraform apply` to complete the import.
#   Once the import is done, remove the import block.
#
# import {
#   to = module.modules_factory_workspace[0].tfe_workspace.this
#   id = "<WORKSPACE_ID>"            # e.g. ws-XXXXXXXXXXXXXXXX
#                                    # or   <ORG_NAME>/<WORKSPACE_NAME>
# }
# -----------------------------------------------------------------------

module "modules_factory_workspace" {
  source         = "./modules/tfe_workspace"
  count          = var.modules_factory_workspace_name != null ? 1 : 0
  name           = lower(var.modules_factory_workspace_name)
  agent_pool_id  = var.modules_factory_agent_pool_id
  description    = var.modules_factory_description
  execution_mode = var.modules_factory_execution_mode
  organization   = tfe_organization.this.name
  project_id     = length(tfe_project.hcp_foundation) > 0 ? tfe_project.hcp_foundation[0].id : null
  tags           = merge(var.modules_factory_tag, { managed_by_terraform = true })

  vcs_repo = {
    # Azure DevOps VCS identifier format: <ado org>/<ado project>/_git/<ado repository>
    # Project name must be URL-encoded (spaces → %20) as required by the HCP Terraform provider.
    identifier     = "${var.azuredevops_organization}/${replace(var.azuredevops_project_name, " ", "%20")}/_git/${module.modules_factory_repository[0].repository.name}"
    branch         = "main"
    oauth_token_id = var.vcs_oauth_token_id
  }
}

# The following module block is used to create and manage the HCP Terraform team required by the `modules factory`.
# Note: the `-git` team has been removed because the workspace is VCS-driven via Azure DevOps
# and no longer requires an API-driven team token to trigger runs.

# -----------------------------------------------------------------------
# HOW TO IMPORT THE MODULES FACTORY HCP TEAM
# -----------------------------------------------------------------------
# Step 1 – Find the team ID.
#   In HCP Terraform: Organization Settings → Teams → click the team →
#   the ID ("team-XXXXXXXXXXXXXXXX") is visible in the browser URL bar.
#   Alternatively, run:
#     curl -s -H "Authorization: Bearer $TFE_TOKEN" \
#          https://app.terraform.io/api/v2/organizations/<org>/teams \
#       | jq '.data[] | {name: .attributes.name, id: .id}'
#
# Step 2 – Find the team token ID.
#   In HCP Terraform: inside the team page, under "Team API Token", the
#   token ID ("at-XXXXXXXXXXXXXXXX") is listed next to each token entry.
#   Alternatively, run:
#     curl -s -H "Authorization: Bearer $TFE_TOKEN" \
#          https://app.terraform.io/api/v2/teams/<TEAM_ID>/authentication-tokens \
#       | jq '.data[] | {description: .attributes.description, id: .id}'
#
# Step 3 – Uncomment the blocks below, fill in the IDs, then run
#   `terraform plan` followed by `terraform apply`.
#   Once the import is done, remove the import blocks.
#
# import {
#   to = module.modules_factory_team_hcp[0].tfe_team.this
#   id = "<TEAM_ID>"                 # e.g. team-XXXXXXXXXXXXXXXX
#                                    # or   <ORG_NAME>/<TEAM_NAME>
# }
#
# import {
#   to = module.modules_factory_team_hcp[0].tfe_team_token.this[0]
#   id = "<TEAM_TOKEN_ID>"           # e.g. at-XXXXXXXXXXXXXXXX
#                                    # or   <TEAM_ID>
# }
# -----------------------------------------------------------------------

module "modules_factory_team_hcp" {
  source       = "./modules/tfe_team"
  count        = var.modules_factory_workspace_name != null ? 1 : 0
  name         = lower(replace("${module.modules_factory_workspace[0].workspace.name}-hcp", "/\\W|_|\\s/", "-"))
  organization = tfe_organization.this.name
  organization_access = {
    manage_membership          = true
    manage_modules             = true
    manage_organization_access = true
    manage_projects            = true
    manage_teams               = true
    manage_workspaces          = true
  }
  token = true
}

# The following resource block is used to create and manage the environment variable required at the workspace level to get authenticated into HCP Terraform by the workspace.

# -----------------------------------------------------------------------
# HOW TO IMPORT THE TFE_TOKEN WORKSPACE VARIABLE
# -----------------------------------------------------------------------
# Step 1 – Find the variable ID.
#   In HCP Terraform: navigate to the workspace → Variables → click the
#   variable → the ID ("var-XXXXXXXXXXXXXXXX") is shown in the URL bar.
#   Alternatively, run:
#     curl -s -H "Authorization: Bearer $TFE_TOKEN" \
#          "https://app.terraform.io/api/v2/workspaces/<WORKSPACE_ID>/vars" \
#       | jq '.data[] | {key: .attributes.key, id: .id}'
#
# Step 2 – Uncomment the block below, fill in the IDs, then run
#   `terraform plan` followed by `terraform apply`.
#   Once the import is done, remove the import block.
#   NOTE: Because the variable is sensitive, Terraform will show a diff
#   on the value after import — this is expected. The value will be
#   updated to match the token from module.modules_factory_team_hcp[0].
#
# import {
#   to = tfe_variable.modules_factory[0]
#   id = "<ORG_NAME>/<WORKSPACE_NAME>/var-XXXXXXXXXXXXXXXX"
# }
# -----------------------------------------------------------------------

resource "tfe_variable" "modules_factory" {
  count        = length(module.modules_factory_team_hcp) > 0 ? 1 : 0
  key          = "TFE_TOKEN"
  value        = module.modules_factory_team_hcp[0].token
  category     = "env"
  sensitive    = true
  workspace_id = module.modules_factory_workspace[0].id
}

# The following resource blocks are used to create and manage the terraform variables required at the workspace level.

# -----------------------------------------------------------------------
# HOW TO IMPORT THE organization_name WORKSPACE VARIABLE
# -----------------------------------------------------------------------
# Step 1 – Find the variable ID.
#   In HCP Terraform: navigate to the workspace → Variables → click the
#   variable → the ID ("var-XXXXXXXXXXXXXXXX") is shown in the URL bar.
#   Alternatively, run:
#     curl -s -H "Authorization: Bearer $TFE_TOKEN" \
#          "https://app.terraform.io/api/v2/workspaces/<WORKSPACE_ID>/vars" \
#       | jq '.data[] | {key: .attributes.key, id: .id}'
#
# Step 2 – Uncomment the block below, fill in the IDs, then run
#   `terraform plan` followed by `terraform apply`.
#   Once the import is done, remove the import block.
#
# import {
#   to = tfe_variable.modules_factory_organization_name[0]
#   id = "<ORG_NAME>/<WORKSPACE_NAME>/var-XXXXXXXXXXXXXXXX"
# }
# -----------------------------------------------------------------------

resource "tfe_variable" "modules_factory_organization_name" {
  count        = length(module.modules_factory_team_hcp) > 0 ? 1 : 0
  key          = "organization_name"
  value        = var.organization_name
  category     = "terraform"
  description  = "(Required) Name of the organization."
  sensitive    = false
  workspace_id = module.modules_factory_workspace[0].id
}

resource "tfe_variable" "modules_factory_vcs_oauth_token_id" {
  count        = length(module.modules_factory_team_hcp) > 0 ? 1 : 0
  key          = "vcs_oauth_token_id"
  value        = var.vcs_oauth_token_id
  category     = "terraform"
  description  = "(Required) The OAuth Token ID of the HCP Terraform VCS Provider connection to use for VCS-driven workspaces."
  sensitive    = false
  workspace_id = module.modules_factory_workspace[0].id
}

resource "tfe_variable" "modules_factory_azuredevops_organization" {
  count        = length(module.modules_factory_team_hcp) > 0 ? 1 : 0
  key          = "azuredevops_organization"
  value        = var.azuredevops_organization
  category     = "terraform"
  description  = "(Required) The name of the Azure DevOps organization."
  sensitive    = false
  workspace_id = module.modules_factory_workspace[0].id
}

resource "tfe_variable" "modules_factory_azuredevops_project_name" {
  count        = length(module.modules_factory_team_hcp) > 0 ? 1 : 0
  key          = "azuredevops_project_name"
  value        = var.azuredevops_project_name
  category     = "terraform"
  description  = "(Required) The name of the Azure DevOps project."
  sensitive    = false
  workspace_id = module.modules_factory_workspace[0].id
}

# The following module block is used to create and manage the Azure DevOps repository used by the `modules factory`.

# -----------------------------------------------------------------------
# HOW TO IMPORT THE MODULES FACTORY AZURE DEVOPS REPOSITORY
# -----------------------------------------------------------------------
# Step 1 – Find the project name and repository name (or GUID).
#   In Azure DevOps: navigate to the repository → the URL contains both:
#   https://dev.azure.com/<org>/<project>/_git/<repository>
#   To get the repository GUID, run:
#     az repos show --org https://dev.azure.com/<org> \
#                   --project "<project>" \
#                   --repository "<repository_name>" \
#                   --query id -o tsv
#
# Step 2 – Uncomment the block below, fill in the IDs, then run
#   `terraform plan` followed by `terraform apply`.
#   Once the import is done, remove the import block.
#   NOTE: After importing, Terraform will detect a diff on the
#   `initialization` block — this is expected and suppressed by the
#   `lifecycle { ignore_changes = [initialization] }` rule in the module.
#
# import {
#   to = module.modules_factory_repository[0].azuredevops_git_repository.this
#   id = "<PROJECT_NAME>/<REPOSITORY_NAME>"   # e.g. MyProject/HCPTerraform-ModulesFactory
#                                             # or   MyProject/<REPOSITORY_GUID>
# }
# -----------------------------------------------------------------------

module "modules_factory_repository" {
  source          = "./modules/azuredevops_repository"
  count           = var.modules_factory_workspace_name != null ? 1 : 0
  project_id      = data.azuredevops_project.this.id
  name            = var.modules_factory_workspace_name
  branch_policies = var.modules_factory_branch_policies
}

# *********************************************************************************************** #
#                                       Projects Factory                                          #
# *********************************************************************************************** #

# The following module block is used to create and manage the workspace used by the `projects factory`.

module "projects_factory_workspace" {
  source         = "./modules/tfe_workspace"
  count          = var.projects_factory_workspace_name != null ? 1 : 0
  name           = lower(var.projects_factory_workspace_name)
  agent_pool_id  = var.projects_factory_agent_pool_id
  description    = var.projects_factory_description
  execution_mode = var.projects_factory_execution_mode
  organization   = tfe_organization.this.name
  project_id     = length(tfe_project.hcp_foundation) > 0 ? tfe_project.hcp_foundation[0].id : null
  tags           = merge(var.projects_factory_tag, { managed_by_terraform = true })

  vcs_repo = {
    # Azure DevOps VCS identifier format: <ado org>/<ado project>/_git/<ado repository>
    # Project name must be URL-encoded (spaces → %20) as required by the HCP Terraform provider.
    identifier     = "${var.azuredevops_organization}/${replace(var.azuredevops_project_name, " ", "%20")}/_git/${module.projects_factory_repository[0].repository.name}"
    branch         = "main"
    oauth_token_id = var.vcs_oauth_token_id
  }
}

# The following module blocks are used to create and manage the HCP Terraform teams required by the `projects factory`.

module "projects_factory_team_hcp" {
  source       = "./modules/tfe_team"
  count        = var.projects_factory_workspace_name != null ? 1 : 0
  name         = lower(replace("${module.projects_factory_workspace[0].workspace.name}-hcp", "/\\W|_|\\s/", "-"))
  organization = tfe_organization.this.name
  organization_access = {
    manage_membership          = true
    manage_organization_access = true
    manage_projects            = true
    manage_teams               = true
    manage_workspaces          = true
  }
  token = true
}

module "projects_factory_team_git" {
  source       = "./modules/tfe_team"
  count        = var.projects_factory_workspace_name != null ? 1 : 0
  name         = lower(replace("${module.projects_factory_workspace[0].workspace.name}-git", "/\\W|_|\\s/", "-"))
  organization = tfe_organization.this.name
  organization_access = {
    manage_projects   = true # This is required to be able to create workspace from no-code module through GitHub Actions.
    manage_workspaces = true # This is required to be able to create workspace from no-code module through GitHub Actions.
  }
  token        = true
  workspace_id = module.projects_factory_workspace[0].id
  workspace_permission = {
    runs = "apply"
  }
}

# The following resource block is used to create and manage the environment variable required at the workspace level to get authenticated into HCP Terraform by the workspace.

resource "tfe_variable" "projects_factory" {
  count        = length(module.projects_factory_team_hcp) > 0 ? 1 : 0
  key          = "TFE_TOKEN"
  value        = module.projects_factory_team_hcp[0].token
  category     = "env"
  sensitive    = true
  workspace_id = module.projects_factory_workspace[0].id
}

# The following resource block is used to create and manage the terraform variable required at the workspace level.

resource "tfe_variable" "projects_factory_organization_name" {
  count        = length(module.projects_factory_team_hcp) > 0 ? 1 : 0
  key          = "organization_name"
  value        = var.organization_name
  category     = "terraform"
  description  = "(Required) Name of the organization."
  sensitive    = false
  workspace_id = module.projects_factory_workspace[0].id
}

# The following module block is used to create and manage the Azure DevOps repository used by the `projects factory`.

module "projects_factory_repository" {
  source          = "./modules/azuredevops_repository"
  count           = var.projects_factory_workspace_name != null ? 1 : 0
  project_id      = data.azuredevops_project.this.id
  name            = var.projects_factory_workspace_name
  branch_policies = var.projects_factory_branch_policies
}

# *********************************************************************************************** #
#                                      Workspaces Factory                                         #
# *********************************************************************************************** #

# The following module block is used to create and manage the workspace used by the `workspaces factory`.

module "workspaces_factory_workspace" {
  source         = "./modules/tfe_workspace"
  count          = var.workspaces_factory_workspace_name != null ? 1 : 0
  name           = lower(var.workspaces_factory_workspace_name)
  agent_pool_id  = var.workspaces_factory_agent_pool_id
  description    = var.workspaces_factory_description
  execution_mode = var.workspaces_factory_execution_mode
  organization   = tfe_organization.this.name
  project_id     = length(tfe_project.hcp_foundation) > 0 ? tfe_project.hcp_foundation[0].id : null
  tags           = merge(var.workspaces_factory_tag, { managed_by_terraform = true })

  vcs_repo = {
    # Azure DevOps VCS identifier format: <ado org>/<ado project>/_git/<ado repository>
    # Project name must be URL-encoded (spaces → %20) as required by the HCP Terraform provider.
    identifier     = "${var.azuredevops_organization}/${replace(var.azuredevops_project_name, " ", "%20")}/_git/${module.workspaces_factory_repository[0].repository.name}"
    branch         = "main"
    oauth_token_id = var.vcs_oauth_token_id
  }
}

# The following module blocks are used to create and manage the HCP Terraform teams required by the `workspaces factory`.

module "workspaces_factory_team_hcp" {
  source       = "./modules/tfe_team"
  count        = var.workspaces_factory_workspace_name != null ? 1 : 0
  name         = lower(replace("${module.workspaces_factory_workspace[0].workspace.name}-hcp", "/\\W|_|\\s/", "-"))
  organization = tfe_organization.this.name
  organization_access = {
    manage_membership          = true
    manage_organization_access = true
    manage_projects            = true
    manage_teams               = true
    manage_workspaces          = true
  }
  token = true
}

module "workspaces_factory_team_git" {
  source       = "./modules/tfe_team"
  count        = var.workspaces_factory_workspace_name != null ? 1 : 0
  name         = lower(replace("${module.workspaces_factory_workspace[0].workspace.name}-git", "/\\W|_|\\s/", "-"))
  organization = tfe_organization.this.name
  organization_access = {
    manage_projects   = true # This is required to be able to create workspace from no-code module through GitHub Actions.
    manage_workspaces = true # This is required to be able to create workspace from no-code module through GitHub Actions.
  }
  token        = true
  workspace_id = module.workspaces_factory_workspace[0].id
  workspace_permission = {
    runs = "apply"
  }
}

# The following resource block is used to create and manage the environment variable required at the workspace level to get authenticated into HCP Terraform by the workspace.

resource "tfe_variable" "workspaces_factory" {
  count        = length(module.workspaces_factory_team_hcp) > 0 ? 1 : 0
  key          = "TFE_TOKEN"
  value        = module.workspaces_factory_team_hcp[0].token
  category     = "env"
  sensitive    = true
  workspace_id = module.workspaces_factory_workspace[0].id
}

# The following resource blocks are used to create and manage the terraform variables required at the workspace level.

resource "tfe_variable" "workspaces_factory_organization_name" {
  count        = length(module.workspaces_factory_team_hcp) > 0 ? 1 : 0
  key          = "organization_name"
  value        = var.organization_name
  category     = "terraform"
  description  = "(Required) Name of the HCP Terraform organization."
  sensitive    = false
  workspace_id = module.workspaces_factory_workspace[0].id
}

resource "tfe_variable" "workspaces_factory_azuredevops_organization" {
  count        = length(module.workspaces_factory_team_hcp) > 0 ? 1 : 0
  key          = "azuredevops_organization"
  value        = var.azuredevops_organization
  category     = "terraform"
  description  = "(Required) The name of the Azure DevOps organization."
  sensitive    = false
  workspace_id = module.workspaces_factory_workspace[0].id
}

resource "tfe_variable" "workspaces_factory_azuredevops_project_name" {
  count        = length(module.workspaces_factory_team_hcp) > 0 ? 1 : 0
  key          = "azuredevops_project_name"
  value        = var.azuredevops_project_name
  category     = "terraform"
  description  = "(Required) The name of the Azure DevOps project."
  sensitive    = false
  workspace_id = module.workspaces_factory_workspace[0].id
}

resource "tfe_variable" "workspaces_factory_vcs_oauth_token_id" {
  count        = length(module.workspaces_factory_team_hcp) > 0 ? 1 : 0
  key          = "vcs_oauth_token_id"
  value        = var.vcs_oauth_token_id
  category     = "terraform"
  description  = "(Required) The OAuth Token ID of the HCP Terraform VCS Provider connection."
  sensitive    = false
  workspace_id = module.workspaces_factory_workspace[0].id
}

# The following module block is used to create and manage the Azure DevOps repository used by the `workspaces factory`.

module "workspaces_factory_repository" {
  source          = "./modules/azuredevops_repository"
  count           = var.workspaces_factory_workspace_name != null ? 1 : 0
  project_id      = data.azuredevops_project.this.id
  name            = var.workspaces_factory_workspace_name
  branch_policies = var.workspaces_factory_branch_policies
}

# *********************************************************************************************** #
#                                     Repositories Factory                                        #
# *********************************************************************************************** #

# The following module block is used to create and manage the workspace used by the `repositories factory`.

module "repositories_factory_workspace" {
  source         = "./modules/tfe_workspace"
  count          = var.repositories_factory_workspace_name != null ? 1 : 0
  name           = lower(var.repositories_factory_workspace_name)
  agent_pool_id  = var.repositories_factory_agent_pool_id
  description    = var.repositories_factory_description
  execution_mode = var.repositories_factory_execution_mode
  organization   = tfe_organization.this.name
  project_id     = length(tfe_project.hcp_foundation) > 0 ? tfe_project.hcp_foundation[0].id : null
  tags           = merge(var.repositories_factory_tag, { managed_by_terraform = true })

  vcs_repo = {
    # Azure DevOps VCS identifier format: <ado org>/<ado project>/_git/<ado repository>
    # Project name must be URL-encoded (spaces → %20) as required by the HCP Terraform provider.
    identifier     = "${var.azuredevops_organization}/${replace(var.azuredevops_project_name, " ", "%20")}/_git/${module.repositories_factory_repository[0].repository.name}"
    branch         = "main"
    oauth_token_id = var.vcs_oauth_token_id
  }
}

# The following module blocks are used to create and manage the HCP Terraform teams required by the `repositories factory`.

module "repositories_factory_team_hcp" {
  source       = "./modules/tfe_team"
  count        = var.repositories_factory_workspace_name != null ? 1 : 0
  name         = lower(replace("${module.repositories_factory_workspace[0].workspace.name}-hcp", "/\\W|_|\\s/", "-"))
  organization = tfe_organization.this.name
  organization_access = {
    manage_projects   = true
    manage_workspaces = true
  }
  token = true
}

module "repositories_factory_team_git" {
  source       = "./modules/tfe_team"
  count        = var.repositories_factory_workspace_name != null ? 1 : 0
  name         = lower(replace("${module.repositories_factory_workspace[0].workspace.name}-git", "/\\W|_|\\s/", "-"))
  organization = tfe_organization.this.name
  organization_access = {
    manage_projects   = true # This is required to be able to create workspace from no-code module through GitHub Actions.
    manage_workspaces = true # This is required to be able to create workspace from no-code module through GitHub Actions.
  }
  token        = true
  workspace_id = module.repositories_factory_workspace[0].id
  workspace_permission = {
    runs = "apply"
  }
}

# The following resource block is used to create and manage the environment variable required at the workspace level to get authenticated into HCP Terraform by the workspace.

resource "tfe_variable" "repositories_factory" {
  count        = length(module.repositories_factory_team_hcp) > 0 ? 1 : 0
  key          = "TFE_TOKEN"
  value        = module.repositories_factory_team_hcp[0].token
  category     = "env"
  sensitive    = true
  workspace_id = module.repositories_factory_workspace[0].id
}

# The following resource block is used to create and manage the terraform variable required at the workspace level.

resource "tfe_variable" "repositories_factory_organization_name" {
  count        = length(module.repositories_factory_team_hcp) > 0 ? 1 : 0
  key          = "organization_name"
  value        = var.organization_name
  category     = "terraform"
  description  = "(Required) Name of the organization."
  sensitive    = false
  workspace_id = module.repositories_factory_workspace[0].id
}

# The following module block is used to create and manage the Azure DevOps repository used by the `repositories factory`.

module "repositories_factory_repository" {
  source          = "./modules/azuredevops_repository"
  count           = var.repositories_factory_workspace_name != null ? 1 : 0
  project_id      = data.azuredevops_project.this.id
  name            = var.repositories_factory_workspace_name
  branch_policies = var.repositories_factory_branch_policies
}
