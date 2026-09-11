# HCP Terraform Teams Terraform Module

HCP Terraform Teams module which manages configuration and life-cycle of
your HCP Terraform teams.

## Permissions

To manage resources, provide a user token from an account with the
`Manage organization access` permission. Alternatively, you can use a team token.

## Authentication

The HCP Terraform provider requires an HCP Terraform API token in order to manage resources.

* Set the `TFE_TOKEN` environment variable. The provider can read the `TFE_TOKEN` environment variable and the token stored there to authenticate.

## Features

* Create and manage HCP Terraform teams.
* Manage team's organization access.
* Manage team's members.
* Generate a team token (and optionally force-regenerate it).
* Manage team's permissions on a project.
* Manage team's permissions on a workspace.

## Usage example

```hcl
module "team" {
  source = "./modules/tfe_team"

  name         = "my-team"
  organization = "my-org"
  token        = true
}
```

## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.13.0)

- <a name="requirement_tfe"></a> [tfe](#requirement\_tfe) (~> 0.79)

## Required Inputs

The following input variables are required:

### <a name="input_name"></a> [name](#input\_name)

Description: (Required) Name of the team.

Type: `string`

### <a name="input_organization"></a> [organization](#input\_organization)

Description: (Required) Name of the organization. If omitted, organization must be defined in the provider config.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_custom_project_access"></a> [custom\_project\_access](#input\_custom\_project\_access)

Description: (Optional) Settings for the team's project access. `settings`: `read`, `update`, or `delete`. `teams`: `none`, `read`, or `manage`.

Type:

```hcl
object({
  settings = optional(string, "read")
  teams    = optional(string, "none")
})
```

Default: `null`

### <a name="input_custom_workspace_access"></a> [custom\_workspace\_access](#input\_custom\_workspace\_access)

Description: (Optional) Settings for the team's workspace access within a project.

Type:

```hcl
object({
  runs           = optional(string, "read")
  sentinel_mocks = optional(string, "none")
  state_versions = optional(string, "none")
  variables      = optional(string, "none")
  create         = optional(bool, false)
  locking        = optional(bool, false)
  delete         = optional(bool, false)
  move           = optional(bool, false)
  run_tasks      = optional(bool, false)
})
```

Default: `null`

### <a name="input_organization_access"></a> [organization\_access](#input\_organization\_access)

Description: (Optional) Settings for the team's organization access.

Type:

```hcl
object({
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
})
```

Default: `null`

### <a name="input_organization_membership_ids"></a> [organization\_membership\_ids](#input\_organization\_membership\_ids)

Description: (Optional) IDs of organization memberships to be added to the team.

Type: `list(string)`

Default: `[]`

### <a name="input_project_access"></a> [project\_access](#input\_project\_access)

Description: (Optional) Type of fixed access to grant. Valid values are `admin`, `maintain`, `write`, `read`, or `custom`. Defaults to `read`.

Type: `string`

Default: `"read"`

### <a name="input_project_id"></a> [project\_id](#input\_project\_id)

Description: (Optional) ID of the project to which the team will be added.

Type: `string`

Default: `null`

### <a name="input_project_name"></a> [project\_name](#input\_project\_name)

Description: (Optional) Name of the project to which the team will be added.

Type: `string`

Default: `null`

### <a name="input_sso_team_id"></a> [sso\_team\_id](#input\_sso\_team\_id)

Description: (Optional) Unique Identifier to control team membership via SAML.

Type: `string`

Default: `null`

### <a name="input_token"></a> [token](#input\_token)

Description: (Optional) If set to `true`, a team token will be generated. Defaults to `false`.

Type: `bool`

Default: `false`

### <a name="input_token_description"></a> [token\_description](#input\_token\_description)

Description: (Optional) The token's description, which must be unique per team.

Type: `string`

Default: `null`

### <a name="input_token_force_regenerate"></a> [token\_force\_regenerate](#input\_token\_force\_regenerate)

Description: (Optional) If set to `true`, a new token will be generated even if a token already exists. This will invalidate the existing token!

Type: `bool`

Default: `false`

### <a name="input_visibility"></a> [visibility](#input\_visibility)

Description: (Optional) The visibility of the team. Valid values are `secret` or `organization`. Defaults to `organization`.

Type: `string`

Default: `"organization"`

### <a name="input_workspace_access"></a> [workspace\_access](#input\_workspace\_access)

Description: (Optional) Type of fixed access to grant. Valid values are `admin`, `read`, `plan`, or `write`. To use custom permissions, use `workspace_permission` instead.

Type: `string`

Default: `null`

### <a name="input_workspace_id"></a> [workspace\_id](#input\_workspace\_id)

Description: (Optional) ID of the workspace to which the team will be added.

Type: `string`

Default: `null`

### <a name="input_workspace_permission"></a> [workspace\_permission](#input\_workspace\_permission)

Description: (Optional) Custom permission settings for the team on a specific workspace.

Type:

```hcl
object({
  runs              = optional(string, "read")
  variables         = optional(string, "none")
  state_versions    = optional(string, "none")
  sentinel_mocks    = optional(string, "none")
  workspace_locking = optional(bool, false)
  run_tasks         = optional(bool, false)
})
```

Default: `null`

## Resources

The following resources are used by this module:

- [tfe_team.this](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/team) (resource) — creates and manages the HCP Terraform team
- [tfe_team_token.this](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/team_token) (resource) — generates a team token when `token = true`
- [tfe_team_organization_members.this](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/team_organization_members) (resource) — manages team membership
- [tfe_team_project_access.this](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/team_project_access) (resource) — manages team access on a project
- [tfe_team_access.this](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/team_access) (resource) — manages team access on a workspace

## Outputs

The following outputs are exported:

### <a name="output_team"></a> [team](#output\_team)

Description: HCP Terraform team resource.

### <a name="output_team_id"></a> [team\_id](#output\_team\_id)

Description: The ID of the team.

### <a name="output_token"></a> [token](#output\_token)

Description: The generated team token.

### <a name="output_token_id"></a> [token\_id](#output\_token\_id)

Description: The ID of the team token.
