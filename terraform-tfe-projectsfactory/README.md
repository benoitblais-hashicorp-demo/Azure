# Projects Factory Terraform Module

Projects Factory module which manages configuration and life-cycle
of your Terraform projects.

## Permissions

### HCP Terraform Permissions

To manage resources, provide a user token from an account with
appropriate permissions. This user should have the `Manage Projects`, `Manage Workspaces`,
`Manage Teams`, `Manage Membership`, and `Manage Organization Access` permission.
Alternatively, you can use a token from a team instead of a user token.

## Authentication

### HCP Terraform Authentication

The HCP Terraform provider requires a HCP Terraform/Terraform Enterprise API token in
order to manage resources.

There are several ways to provide the required token:

* Set the `TFE_TOKEN` environment variable. The provider can read the `TFE_TOKEN` environment variable and the token stored there to authenticate.

## Features

* Manages configuration and life-cycle of HCP Terraform resources:
  * Project
  * Variable set (project-scoped) with configurable variables
  * Teams with configurable SSO team ID and project access level (`read` or `write`)

## Usage example

```hcl
module "project" {
  source  = "app.terraform.io/<organization_name>/projectsfactory/tfe"
  version = "0.0.0"

  project_name = "my-project"
}
```

## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.13.0)

- <a name="requirement_tfe"></a> [tfe](#requirement\_tfe) (~> 0.79)

## Modules

The following Modules are called:

### <a name="module_team_read"></a> [team\_read](#module\_team\_read)

Source: `./modules/tfe_team`

Creates a read-access HCP Terraform team scoped to the project. Provisioned only when `sso_read_team_id` is set.

### <a name="module_team_write"></a> [team\_write](#module\_team\_write)

Source: `./modules/tfe_team`

Creates a write-access HCP Terraform team scoped to the project. Provisioned only when `sso_write_team_id` is set.

## Required Inputs

The following input variables are required:

### <a name="input_project_name"></a> [project\_name](#input\_project\_name)

Description: (Required) Name of the project.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_organization_name"></a> [organization\_name](#input\_organization\_name)

Description: (Optional) Name of the HCP Terraform organization. Configured automatically via the project variable set.

Type: `string`

Default: `null`

### <a name="input_project_description"></a> [project\_description](#input\_project\_description)

Description: (Optional) A description for the project.

Type: `string`

Default: `null`

### <a name="input_project_tags"></a> [project\_tags](#input\_project\_tags)

Description: (Optional) A map of key-value tags to add to the project.

Type: `map(string)`

Default: `null`

### <a name="input_sso_read_team_id"></a> [sso\_read\_team\_id](#input\_sso\_read\_team\_id)

Description: (Optional) The SSO team ID to associate with the read access team.

Type: `string`

Default: `null`

### <a name="input_sso_write_team_id"></a> [sso\_write\_team\_id](#input\_sso\_write\_team\_id)

Description: (Optional) The SSO team ID to associate with the write access team.

Type: `string`

Default: `null`

### <a name="input_variable_set_variables"></a> [variable\_set\_variables](#input\_variable\_set\_variables)

Description: (Optional) List of variables to add to the project-scoped variable set.
  - `key`         : (Required) Name of the variable.
  - `value`       : (Required) Value of the variable.
  - `category`    : (Required) Whether this is a Terraform or environment variable. Valid values are `terraform` or `env`.
  - `description` : (Optional) Description of the variable.
  - `hcl`         : (Optional) Whether to evaluate the value of the variable as HCL. Defaults to `false`.
  - `sensitive`   : (Optional) Whether the value is sensitive. Defaults to `false`.

Type:

```hcl
list(object({
  key         = string
  value       = string
  category    = string
  description = optional(string)
  hcl         = optional(bool, false)
  sensitive   = optional(bool, false)
}))
```

Default: `[]`

## Resources

The following resources are used by this module:

- [tfe_project.this](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/project) (resource) — HCP Terraform project
- [tfe_variable_set.this](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable_set) (resource) — project-scoped variable set for child workspaces
- [tfe_project_variable_set.this](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/project_variable_set) (resource) — applies the variable set to all workspaces in the project
- [tfe_variable.this](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) (resource) — variables stored in the project-scoped variable set
- [module.team_read](./modules/tfe_team) (module) — creates the read-access team and assigns it to the project
- [module.team_write](./modules/tfe_team) (module) — creates the write-access team and assigns it to the project

## Outputs

The following outputs are exported:

### <a name="output_project"></a> [project](#output\_project)

Description: The HCP Terraform project.

### <a name="output_project_id"></a> [project\_id](#output\_project\_id)

Description: The ID of the HCP Terraform project.

### <a name="output_team_read"></a> [team\_read](#output\_team\_read)

Description: The read access team.

### <a name="output_team_read_id"></a> [team\_read\_id](#output\_team\_read\_id)

Description: The ID of the read access team.

### <a name="output_team_write"></a> [team\_write](#output\_team\_write)

Description: The write access team.

### <a name="output_team_write_id"></a> [team\_write\_id](#output\_team\_write\_id)

Description: The ID of the write access team.

### <a name="output_variable_ids"></a> [variable\_ids](#output\_variable\_ids)

Description: The IDs of the HCP Terraform variables within the variable set at the project level.

### <a name="output_variable_set_id"></a> [variable\_set\_id](#output\_variable\_set\_id)

Description: The ID of the HCP Terraform variable set at the project level.

### <a name="output_project_variable_set_id"></a> [project\_variable\_set\_id](#output\_project\_variable\_set\_id)

Description: The ID of the tfe_project_variable_set association resource.
