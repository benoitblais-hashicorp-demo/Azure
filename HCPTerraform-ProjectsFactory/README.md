# HCP Terraform Projects Factory

Code which manages configuration and life-cycle of the HCP Terraform
projects factory. It is designed to be used from a dedicated
API-Driven HCP Terraform workspace that would provision and manage the
configuration using Terraform code (IaC).

> Project creation and management is facilitated through a no-code
> module. Each no-code module must be provisioned within the dedicated project
> to ensure proper variable input configuration and management.

## Permissions

### HCP Terraform Permissions

To manage the resources, provide a user token from an account with appropriate
permissions. This user should have the `Manage Projects`, `Manage Workspaces`,
`Manage Teams`, `Manage Membership`, and `Manage Organization Access` permission.
Alternatively, you can use a token from a team instead of a user token.

## Authentication

### HCP Terraform Authentication

The HCP Terraform provider requires an HCP Terraform API token in order to manage
resources.

There are several ways to provide the required token:

* Set the `TFE_TOKEN` environment variable. The provider can read the `TFE_TOKEN` environment variable and the token stored there to authenticate.

## Features

* Manages configuration and life-cycle of HCP Terraform resources:
  * Project
  * Variable set (project-scoped, applied to all workspaces in the project)
    * `TFE_TOKEN` — team token injected for child workspace use
    * `organization_name` — HCP Terraform organization name injected for child workspace use
  * Team with organization-level access and a team token

## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.13.0)

- <a name="requirement_tfe"></a> [tfe](#requirement\_tfe) (~> 0.79)

## Modules

The following Modules are called:

### <a name="module_projects_factory_team_hcp"></a> [projects\_factory\_team\_hcp](#module\_projects\_factory\_team\_hcp)

Source: `./modules/tfe_team`

Creates an HCP Terraform team with organization-level access and generates a team token used by child workspaces.

## Required Inputs

The following input variables are required:

### <a name="input_organization_name"></a> [organization\_name](#input\_organization\_name)

Description: (Required) Name of the HCP Terraform organization.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_project_description"></a> [project\_description](#input\_project\_description)

Description: (Optional) A description for the project.

Type: `string`

Default: `null`

### <a name="input_project_name"></a> [project\_name](#input\_project\_name)

Description: (Optional) Name of the HCP Terraform project.

Type: `string`

Default: `"Terraform Projects Factory"`

### <a name="input_project_tags"></a> [project\_tags](#input\_project\_tags)

Description: (Optional) A map of key-value tags to add to the project.

Type: `map(string)`

Default: `null`

## Resources

The following resources are used by this module:

- [tfe_project.this](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/project) (resource) — HCP Terraform project for all child workspaces
- [tfe_variable_set.this](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable_set) (resource) — project-scoped variable set for child workspaces
- [tfe_project_variable_set.this](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/project_variable_set) (resource) — applies the variable set to all workspaces in the project
- [tfe_variable.tfe_token](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) (resource) — `TFE_TOKEN` env variable in the variable set (team token)
- [tfe_variable.organization_name](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) (resource) — `organization_name` Terraform variable in the variable set
- [module.projects_factory_team_hcp](./modules/tfe_team) (module) — creates the team, configures organization access, and generates the team token

## Outputs

No outputs.
