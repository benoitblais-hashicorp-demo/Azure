# HCP Terraform Foundation

Code which manages configuration and life-cycle of all the HCP Terraform
foundation. It is designed to be used from a dedicated VCS-Driven Terraform
workspace that would provision and manage the configuration using
Terraform code (IaC).

## Permissions

### HCP Terraform Permissions

To manage the resources from that code, provide a token from an account with
`owner` permissions. Alternatively, you can use a token from the `owner` team
instead of a user token.

### Azure DevOps Permissions

To manage the Azure DevOps resources, provide a Personal Access Token (PAT) or
configure a service principal with appropriate permissions. The identity must have:

* **Code**: Read & Write (to create and configure repositories)
* **Project and Team**: Read (to read project information)
* **Build**: Read & Execute (required for branch policies that reference build definitions)

## Authentication

### HCP Terraform Authentication

The HCP Terraform provider requires a HCP Terraform/Terraform Enterprise API token in
order to manage resources.

There are several ways to provide the required token:

* Set the `token` argument in the provider configuration. You can set the token argument in the provider configuration. Use an
input variable for the token.
* Set the `TFE_TOKEN` environment variable. The provider can read the TFE\_TOKEN environment variable and the token stored there
to authenticate.

### Azure DevOps Authentication

The Azure DevOps provider requires a Personal Access Token (PAT) or service principal credentials
in order to manage resources.

There are several ways to provide the required credentials:

* Set the `AZDO_ORG_SERVICE_URL` environment variable to your Azure DevOps organization URL
  (e.g., `https://dev.azure.com/your-org`).
* Set the `AZDO_PERSONAL_ACCESS_TOKEN` environment variable to authenticate with a PAT.

Alternatively, for service principal (OIDC/client secret) authentication, set:

* `AZDO_CLIENT_ID` – the service principal client ID.
* `AZDO_CLIENT_SECRET` or configure OIDC with `AZDO_TENANT_ID`.

> **Note:** The PAT must be created with the scopes listed under **Azure DevOps Permissions** above.
> Token TTL should be set according to your organization's security policy.

## Features

* Manages configuration and life-cycle of HCP Terraform resources:
  * projects
  * workspaces
  * teams
  * variable sets
  * variables
  * notifications
  * run tasks
* Manages Azure DevOps repository configuration:
  * Git repositories (one per factory workspace)
  * Branch policies (minimum reviewers, comment resolution, merge types, auto reviewers)

## Prerequisite

In order to deploy the configuration from this code, you must first create
an organization. You must then configure a [VCS Provider](docs/VCS-Provider.md)
before manually creating a dedicated VCS-driven workspace in the UI.

To authenticate into HCP Terraform during configuration deployment, an
API token must be created. This token must come from an account with `owner`
permission or the `owner` team. An environment variable `TFE_TOKEN` must be
created in the previously created workspace with the value of the generated token.

## Manual Configurations

Currently, there are some HCP Terraform organization-level settings that are not fully exposed or supported by the `hashicorp/tfe` Terraform provider and must be configured manually via the HCP Terraform UI:

1. **Maximum Time To Live (TTL) for API Tokens**: You can configure a maximum TTL for user and team API tokens to enhance security. This must be set manually in your Organization Settings.
2. **Recoverable Items (Data Retention Policy)**: Enabling or configuring the retention window for deleted (recoverable) workspaces, networks, or other items is not yet possible through Terraform.
3. **IP Allow List (Inbound Allow List)**: Restricting inbound access to HCP Terraform workspaces and API endpoints to specific IP ranges must be done natively in the UI.

## External Documentation

The following external documentation was used to develop this code:

* [Terraform Documentation](https://developer.hashicorp.com/terraform/docs)
* [HCP Terraform Provider Documentation](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs)
* [Azure DevOps Terraform Provider Documentation](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs)
* [Azure DevOps REST API — Git Repositories](https://docs.microsoft.com/en-us/rest/api/azure/devops/git/repositories?view=azure-devops-rest-7.0)
* [Azure DevOps REST API — Policy Configurations](https://docs.microsoft.com/en-us/rest/api/azure/devops/policy/configurations?view=azure-devops-rest-7.0)
* [Azure DevOps PAT Scopes](https://learn.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate)

## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.13.0)

- <a name="requirement_azuredevops"></a> [azuredevops](#requirement\_azuredevops) (~> 1.16)

- <a name="requirement_tfe"></a> [tfe](#requirement\_tfe) (~> 0.79)

- <a name="requirement_time"></a> [time](#requirement\_time) (~> 0.14)

## Modules

The following Modules are called:

### <a name="module_agent_pool"></a> [agent\_pool](#module\_agent\_pool)

Source: ./modules/tfe_agent

### <a name="module_teams"></a> [teams](#module\_teams)

Source: ./modules/tfe_team

### <a name="module_policies_factory_workspace"></a> [policies\_factory\_workspace](#module\_policies\_factory\_workspace)

Source: ./modules/tfe_workspace

### <a name="module_policies_factory_team_hcp"></a> [policies\_factory\_team\_hcp](#module\_policies\_factory\_team\_hcp)

Source: ./modules/tfe_team

### <a name="module_policies_factory_repository"></a> [policies\_factory\_repository](#module\_policies\_factory\_repository)

Source: ./modules/azuredevops_repository

### <a name="module_modules_factory_workspace"></a> [modules\_factory\_workspace](#module\_modules\_factory\_workspace)

Source: ./modules/tfe_workspace

### <a name="module_modules_factory_team_hcp"></a> [modules\_factory\_team\_hcp](#module\_modules\_factory\_team\_hcp)

Source: ./modules/tfe_team

### <a name="module_modules_factory_team_git"></a> [modules\_factory\_team\_git](#module\_modules\_factory\_team\_git)

Source: ./modules/tfe_team

### <a name="module_modules_factory_repository"></a> [modules\_factory\_repository](#module\_modules\_factory\_repository)

Source: ./modules/azuredevops_repository

### <a name="module_projects_factory_workspace"></a> [projects\_factory\_workspace](#module\_projects\_factory\_workspace)

Source: ./modules/tfe_workspace

### <a name="module_projects_factory_team_hcp"></a> [projects\_factory\_team\_hcp](#module\_projects\_factory\_team\_hcp)

Source: ./modules/tfe_team

### <a name="module_projects_factory_team_git"></a> [projects\_factory\_team\_git](#module\_projects\_factory\_team\_git)

Source: ./modules/tfe_team

### <a name="module_projects_factory_repository"></a> [projects\_factory\_repository](#module\_projects\_factory\_repository)

Source: ./modules/azuredevops_repository

### <a name="module_workspaces_factory_workspace"></a> [workspaces\_factory\_workspace](#module\_workspaces\_factory\_workspace)

Source: ./modules/tfe_workspace

### <a name="module_workspaces_factory_team_hcp"></a> [workspaces\_factory\_team\_hcp](#module\_workspaces\_factory\_team\_hcp)

Source: ./modules/tfe_team

### <a name="module_workspaces_factory_team_git"></a> [workspaces\_factory\_team\_git](#module\_workspaces\_factory\_team\_git)

Source: ./modules/tfe_team

### <a name="module_workspaces_factory_repository"></a> [workspaces\_factory\_repository](#module\_workspaces\_factory\_repository)

Source: ./modules/azuredevops_repository

### <a name="module_repositories_factory_workspace"></a> [repositories\_factory\_workspace](#module\_repositories\_factory\_workspace)

Source: ./modules/tfe_workspace

### <a name="module_repositories_factory_team_hcp"></a> [repositories\_factory\_team\_hcp](#module\_repositories\_factory\_team\_hcp)

Source: ./modules/tfe_team

### <a name="module_repositories_factory_team_git"></a> [repositories\_factory\_team\_git](#module\_repositories\_factory\_team\_git)

Source: ./modules/tfe_team

### <a name="module_repositories_factory_repository"></a> [repositories\_factory\_repository](#module\_repositories\_factory\_repository)

Source: ./modules/azuredevops_repository

## Required Inputs

The following input variables are required:

### <a name="input_azuredevops_organization"></a> [azuredevops\_organization](#input\_azuredevops\_organization)

Description: (Required) The name of the Azure DevOps organization (the segment after `dev.azure.com/` in the URL). Used to build the VCS identifier for HCP Terraform workspaces.

Type: `string`

### <a name="input_azuredevops_project_name"></a> [azuredevops\_project\_name](#input\_azuredevops\_project\_name)

Description: (Required) The name of the Azure DevOps project in which all factory repositories will be created. Used to look up the project UUID at plan time.

Type: `string`

### <a name="input_organization_email"></a> [organization\_email](#input\_organization\_email)

Description: (Required) Admin email address.

Type: `string`

### <a name="input_organization_name"></a> [organization\_name](#input\_organization\_name)

Description: (Required) Name of the organization.

Type: `string`

### <a name="input_vcs_oauth_token_id"></a> [vcs\_oauth\_token\_id](#input\_vcs\_oauth\_token\_id)

Description: (Required) The OAuth Token ID of the HCP Terraform VCS Provider connection to use for VCS-driven workspaces. Find it in HCP Terraform UI: Organization Settings → VCS Providers → click the connection → the value starts with `ot-` (not `oc-`).

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_agent_pools"></a> [agent\_pools](#input\_agent\_pools)

Description: (Optional) A list with the name of all the agent pools available at the organization level.

Type: `list(string)`

Default: `[]`

### <a name="input_aggregated_commit_status_enabled"></a> [aggregated\_commit\_status\_enabled](#input\_aggregated\_commit\_status\_enabled)

Description: (Optional) Whether or not to enable Aggregated Status Checks. If enabled, `send_passing_statuses_for_untriggered_speculative_plans` must be `false`. Default to `true`.

Type: `bool`

Default: `true`

### <a name="input_allow_force_delete_workspaces"></a> [allow\_force\_delete\_workspaces](#input\_allow\_force\_delete\_workspaces)

Description: (Optional) Whether workspace administrators are permitted to delete workspaces with resources under management. Defaults to `false`.

Type: `bool`

Default: `false`

### <a name="input_assessments_enforced"></a> [assessments\_enforced](#input\_assessments\_enforced)

Description: (Optional) Whether to force health assessments (drift detection) on all eligible workspaces. Default to `true`.

Type: `bool`

Default: `true`

### <a name="input_collaborator_auth_policy"></a> [collaborator\_auth\_policy](#input\_collaborator\_auth\_policy)

Description: (Optional) Authentication policy. Valid values are `password` or `two_factor_mandatory`. Default to `two_factor_mandatory`.

Type: `string`

Default: `"two_factor_mandatory"`

### <a name="input_cost_estimation_enabled"></a> [cost\_estimation\_enabled](#input\_cost\_estimation\_enabled)

Description: (Optional) Whether or not the cost estimation feature is enabled for all workspaces in the organization. Defaults to `true`.

Type: `bool`

Default: `true`

### <a name="input_default_execution_mode"></a> [default\_execution\_mode](#input\_default\_execution\_mode)

Description: (Optional) Which execution mode to use as the default for all workspaces in the organization. Valid values are `remote`, `local` or `agent`. Default to `remote`.

Type: `string`

Default: `"remote"`

### <a name="input_hcp_foundation_project_description"></a> [hcp\_foundation\_project\_description](#input\_hcp\_foundation\_project\_description)

Description: (Optional) A description for the HCP Terraform Foundation project.

Type: `string`

Default: `null`

### <a name="input_hcp_foundation_project_name"></a> [hcp\_foundation\_project\_name](#input\_hcp\_foundation\_project\_name)

Description: (Optional) Name of the HCP Terraform Foundation project.

Type: `string`

Default: `"HCP Terraform"`

### <a name="input_hcp_foundation_project_tags"></a> [hcp\_foundation\_project\_tags](#input\_hcp\_foundation\_project\_tags)

Description: (Optional) A map of key-value tags to add to the HCP Terraform Foundation project.

Type: `map(string)`

Default: `null`

### <a name="input_modules_factory_agent_pool_id"></a> [modules\_factory\_agent\_pool\_id](#input\_modules\_factory\_agent\_pool\_id)

Description: (Optional) The ID of an agent pool for the `modules factory` workspace. Requires `execution_mode = "agent"`.

Type: `string`

Default: `null`

### <a name="input_modules_factory_branch_policies"></a> [modules\_factory\_branch\_policies](#input\_modules\_factory\_branch\_policies)

Description: (Optional) Branch policy configurations for the `modules factory` Azure DevOps repository.

Type: See `modules/azuredevops_repository` variable `branch_policies`.

Default: Protection on `refs/heads/main` with comment resolution, 1 required reviewer, squash and no-fast-forward merge strategies.

### <a name="input_modules_factory_description"></a> [modules\_factory\_description](#input\_modules\_factory\_description)

Description: (Optional) A description for the `modules factory` workspace.

Type: `string`

Default: `"Code to provision and manage HCP Terraform modules using Terraform code (IaC)."`

### <a name="input_modules_factory_execution_mode"></a> [modules\_factory\_execution\_mode](#input\_modules\_factory\_execution\_mode)

Description: (Optional) Execution mode for the `modules factory` workspace. Valid values: `remote`, `local`, `agent`.

Type: `string`

Default: `null`

### <a name="input_modules_factory_tag"></a> [modules\_factory\_tag](#input\_modules\_factory\_tag)

Description: (Optional) Tags for the `modules factory` workspace.

Type: `map(string)`

Default: `null`

### <a name="input_modules_factory_workspace_name"></a> [modules\_factory\_workspace\_name](#input\_modules\_factory\_workspace\_name)

Description: (Optional) Name of the `modules factory` workspace.

Type: `string`

Default: `"HCPTerraform-ModulesFactory"`

### <a name="input_owners_team_saml_role_id"></a> [owners\_team\_saml\_role\_id](#input\_owners\_team\_saml\_role\_id)

Description: (Optional) SAML role ID for the owners team.

Type: `string`

Default: `null`

### <a name="input_policies_factory_agent_pool_id"></a> [policies\_factory\_agent\_pool\_id](#input\_policies\_factory\_agent\_pool\_id)

Description: (Optional) The ID of an agent pool for the `policies factory` workspace. Requires `execution_mode = "agent"`.

Type: `string`

Default: `null`

### <a name="input_policies_factory_branch_policies"></a> [policies\_factory\_branch\_policies](#input\_policies\_factory\_branch\_policies)

Description: (Optional) Branch policy configurations for the `policies factory` Azure DevOps repository.

Type: See `modules/azuredevops_repository` variable `branch_policies`.

Default: Protection on `refs/heads/main` with comment resolution, 1 required reviewer, squash and no-fast-forward merge strategies.

### <a name="input_policies_factory_description"></a> [policies\_factory\_description](#input\_policies\_factory\_description)

Description: (Optional) A description for the `policies factory` workspace.

Type: `string`

Default: `"Code to provision and manage HCP Terraform policies using Terraform code (IaC)."`

### <a name="input_policies_factory_execution_mode"></a> [policies\_factory\_execution\_mode](#input\_policies\_factory\_execution\_mode)

Description: (Optional) Execution mode for the `policies factory` workspace. Valid values: `remote`, `local`, `agent`.

Type: `string`

Default: `null`

### <a name="input_policies_factory_tag"></a> [policies\_factory\_tag](#input\_policies\_factory\_tag)

Description: (Optional) Tags for the `policies factory` workspace.

Type: `map(string)`

Default: `null`

### <a name="input_policies_factory_workspace_name"></a> [policies\_factory\_workspace\_name](#input\_policies\_factory\_workspace\_name)

Description: (Optional) Name of the `policies factory` workspace.

Type: `string`

Default: `"HCPTerraform-PoliciesFactory"`

### <a name="input_projects_factory_agent_pool_id"></a> [projects\_factory\_agent\_pool\_id](#input\_projects\_factory\_agent\_pool\_id)

Description: (Optional) The ID of an agent pool for the `projects factory` workspace. Requires `execution_mode = "agent"`.

Type: `string`

Default: `null`

### <a name="input_projects_factory_branch_policies"></a> [projects\_factory\_branch\_policies](#input\_projects\_factory\_branch\_policies)

Description: (Optional) Branch policy configurations for the `projects factory` Azure DevOps repository.

Type: See `modules/azuredevops_repository` variable `branch_policies`.

Default: Protection on `refs/heads/main` with comment resolution, 1 required reviewer, squash and no-fast-forward merge strategies.

### <a name="input_projects_factory_description"></a> [projects\_factory\_description](#input\_projects\_factory\_description)

Description: (Optional) A description for the `projects factory` workspace.

Type: `string`

Default: `"Code to provision and manage HCP Terraform projects using Terraform code (IaC)."`

### <a name="input_projects_factory_execution_mode"></a> [projects\_factory\_execution\_mode](#input\_projects\_factory\_execution\_mode)

Description: (Optional) Execution mode for the `projects factory` workspace. Valid values: `remote`, `local`, `agent`.

Type: `string`

Default: `null`

### <a name="input_projects_factory_tag"></a> [projects\_factory\_tag](#input\_projects\_factory\_tag)

Description: (Optional) Tags for the `projects factory` workspace.

Type: `map(string)`

Default: `null`

### <a name="input_projects_factory_workspace_name"></a> [projects\_factory\_workspace\_name](#input\_projects\_factory\_workspace\_name)

Description: (Optional) Name of the `projects factory` workspace.

Type: `string`

Default: `"HCPTerraform-ProjectsFactory"`

### <a name="input_repositories_factory_agent_pool_id"></a> [repositories\_factory\_agent\_pool\_id](#input\_repositories\_factory\_agent\_pool\_id)

Description: (Optional) The ID of an agent pool for the `repositories factory` workspace. Requires `execution_mode = "agent"`.

Type: `string`

Default: `null`

### <a name="input_repositories_factory_branch_policies"></a> [repositories\_factory\_branch\_policies](#input\_repositories\_factory\_branch\_policies)

Description: (Optional) Branch policy configurations for the `repositories factory` Azure DevOps repository.

Type: See `modules/azuredevops_repository` variable `branch_policies`.

Default: Protection on `refs/heads/main` with comment resolution, 1 required reviewer, squash and no-fast-forward merge strategies.

### <a name="input_repositories_factory_description"></a> [repositories\_factory\_description](#input\_repositories\_factory\_description)

Description: (Optional) A description for the `repositories factory` workspace.

Type: `string`

Default: `"Code to provision and manage Azure DevOps repositories using Terraform code (IaC)."`

### <a name="input_repositories_factory_execution_mode"></a> [repositories\_factory\_execution\_mode](#input\_repositories\_factory\_execution\_mode)

Description: (Optional) Execution mode for the `repositories factory` workspace. Valid values: `remote`, `local`, `agent`.

Type: `string`

Default: `null`

### <a name="input_repositories_factory_tag"></a> [repositories\_factory\_tag](#input\_repositories\_factory\_tag)

Description: (Optional) Tags for the `repositories factory` workspace.

Type: `map(string)`

Default: `null`

### <a name="input_repositories_factory_workspace_name"></a> [repositories\_factory\_workspace\_name](#input\_repositories\_factory\_workspace\_name)

Description: (Optional) Name of the `repositories factory` workspace.

Type: `string`

Default: `"AzureDevOps-RepositoriesFactory"`

### <a name="input_send_passing_statuses_for_untriggered_speculative_plans"></a> [send\_passing\_statuses\_for\_untriggered\_speculative\_plans](#input\_send\_passing\_statuses\_for\_untriggered\_speculative\_plans)

Description: (Optional) Whether or not to send VCS status updates for untriggered speculative plans. Defaults to `false`.

Type: `bool`

Default: `false`

### <a name="input_session_remember_minutes"></a> [session\_remember\_minutes](#input\_session\_remember\_minutes)

Description: (Optional) Session expiration in minutes. Defaults to `20160`.

Type: `number`

Default: `null`

### <a name="input_session_timeout_minutes"></a> [session\_timeout\_minutes](#input\_session\_timeout\_minutes)

Description: (Optional) Session timeout after inactivity in minutes. Defaults to `20160`.

Type: `number`

Default: `null`

### <a name="input_speculative_plan_management_enabled"></a> [speculative\_plan\_management\_enabled](#input\_speculative\_plan\_management\_enabled)

Description: (Optional) Whether to cancel pending speculative plans when a newer commit is pushed. Default to `true`.

Type: `bool`

Default: `true`

### <a name="input_stacks_enabled"></a> [stacks\_enabled](#input\_stacks\_enabled)

Description: (Optional) Whether or not to enable Stacks. Defaults to `true`.

Type: `bool`

Default: `true`

### <a name="input_teams"></a> [teams](#input\_teams)

Description:   (Optional) The teams block supports the following:
    name                         : (Required) Name of the team.
    organization\_access          : (Optional) Organization-level access settings.
    sso\_team\_id                  : (Optional) Unique Identifier to control team membership via SAML.
    token                        : (Optional) If `true`, a team token is generated with a 24-month expiration (automatic).
    token\_description            : (Optional) The token's description. Required if creating multiple tokens for a single team.
    token\_force\_regenerate       : (Optional) If `true`, regenerates an existing token. This will invalidate the existing token!
    visibility                   : (Optional) The visibility of the team (`secret` or `organization`).

Type:

```hcl
list(object({
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
```

Default: `[]`

### <a name="input_user_tokens_enabled"></a> [user\_tokens\_enabled](#input\_user\_tokens\_enabled)

Description: (Optional) Whether user tokens can be used to read or update the organization.

Type: `bool`

Default: `true`

### <a name="input_workspaces_factory_agent_pool_id"></a> [workspaces\_factory\_agent\_pool\_id](#input\_workspaces\_factory\_agent\_pool\_id)

Description: (Optional) The ID of an agent pool for the `workspaces factory` workspace. Requires `execution_mode = "agent"`.

Type: `string`

Default: `null`

### <a name="input_workspaces_factory_branch_policies"></a> [workspaces\_factory\_branch\_policies](#input\_workspaces\_factory\_branch\_policies)

Description: (Optional) Branch policy configurations for the `workspaces factory` Azure DevOps repository.

Type: See `modules/azuredevops_repository` variable `branch_policies`.

Default: Protection on `refs/heads/main` with comment resolution, 1 required reviewer, squash and no-fast-forward merge strategies.

### <a name="input_workspaces_factory_description"></a> [workspaces\_factory\_description](#input\_workspaces\_factory\_description)

Description: (Optional) A description for the `workspaces factory` workspace.

Type: `string`

Default: `"Code to provision and manage HCP Terraform workspaces using Terraform code (IaC)."`

### <a name="input_workspaces_factory_execution_mode"></a> [workspaces\_factory\_execution\_mode](#input\_workspaces\_factory\_execution\_mode)

Description: (Optional) Execution mode for the `workspaces factory` workspace. Valid values: `remote`, `local`, `agent`.

Type: `string`

Default: `null`

### <a name="input_workspaces_factory_tag"></a> [workspaces\_factory\_tag](#input\_workspaces\_factory\_tag)

Description: (Optional) Tags for the `workspaces factory` workspace.

Type: `map(string)`

Default: `null`

### <a name="input_workspaces_factory_workspace_name"></a> [workspaces\_factory\_workspace\_name](#input\_workspaces\_factory\_workspace\_name)

Description: (Optional) Name of the `workspaces factory` workspace.

Type: `string`

Default: `"HCPTerraform-WorkspacesFactory"`

## Data Sources

The following data sources are used by this module:

- [azuredevops_project.this](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/data-sources/project) (data source) — looks up the Azure DevOps project UUID from `var.azuredevops_project_name`

## Resources

The following resources are used by this module:

- [tfe_organization.this](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/organization) (resource)
- [tfe_organization_default_settings.this](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/organization_default_settings) (resource)
- [tfe_project.hcp_foundation](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/project) (resource)
- [tfe_variable.policies_factory](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) (resource) — `TFE_TOKEN` env variable for the `policies factory` workspace
- [tfe_variable.policies_factory_organization_name](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) (resource) — `organization_name` Terraform variable for the `policies factory` workspace
- [tfe_variable.modules_factory](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) (resource) — `TFE_TOKEN` env variable for the `modules factory` workspace
- [tfe_variable.modules_factory_organization_name](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) (resource) — `organization_name` Terraform variable for the `modules factory` workspace
- [tfe_variable.modules_factory_vcs_oauth_token_id](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) (resource) — `vcs_oauth_token_id` Terraform variable for the `modules factory` workspace
- [tfe_variable.modules_factory_azuredevops_organization](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) (resource) — `azuredevops_organization` Terraform variable for the `modules factory` workspace
- [tfe_variable.modules_factory_azuredevops_project_name](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) (resource) — `azuredevops_project_name` Terraform variable for the `modules factory` workspace
- [tfe_variable.projects_factory](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) (resource) — `TFE_TOKEN` env variable for the `projects factory` workspace
- [tfe_variable.projects_factory_organization_name](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) (resource) — `organization_name` Terraform variable for the `projects factory` workspace
- [tfe_variable.workspaces_factory](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) (resource) — `TFE_TOKEN` env variable for the `workspaces factory` workspace
- [tfe_variable.workspaces_factory_organization_name](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) (resource) — `organization_name` Terraform variable for the `workspaces factory` workspace
- [tfe_variable.workspaces_factory_azuredevops_organization](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) (resource) — `azuredevops_organization` Terraform variable for the `workspaces factory` workspace
- [tfe_variable.workspaces_factory_azuredevops_project_name](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) (resource) — `azuredevops_project_name` Terraform variable for the `workspaces factory` workspace
- [tfe_variable.workspaces_factory_vcs_oauth_token_id](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) (resource) — `vcs_oauth_token_id` Terraform variable for the `workspaces factory` workspace
- [tfe_variable.repositories_factory](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) (resource) — `TFE_TOKEN` env variable for the `repositories factory` workspace
- [tfe_variable.repositories_factory_organization_name](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) (resource) — `organization_name` Terraform variable for the `repositories factory` workspace

## Outputs

The following outputs are exported:

### <a name="output_teams"></a> [teams](#output\_teams)

Description: List of Teams created

<!-- markdownlint-enable -->