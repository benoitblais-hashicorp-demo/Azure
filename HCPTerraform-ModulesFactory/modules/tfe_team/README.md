# HCP Terraform Teams Terraform module

HCP Terraform Teams module which manages configuration and life-cycle of
your HCP Terraform teams.

## Permissions

To manage resources, provide a user token from an account with appropriate
permissions. This user should have the `Manage organization access` permission. 
Alternatively, you can use a token from a team instead of a user token.

## Authentication

The HCP Terraform provider requires a HCP Terraform/Terraform Enterprise API token in 
order to manage resources.

There are several ways to provide the required token:

- Set the `token` argument in the provider configuration. You can set the token argument in the provider configuration. Use an
input variable for the token.
- Set the `TFE_TOKEN` environment variable. The provider can read the TFE_TOKEN environment variable and the token stored there
to authenticate.

## Features

- Create and manage HCP Terraform teams.
- Manage team's organization access.
- Manage team's members.
- Generates a new team token and overrides existing token if one exists.
- Manage team's permissions on a project.
- Manage team's permissions on a workspace.

## Usage example
```hcl
module "team" {
  source = "./modules/tfe_team"

  name           = "Team Name"
  sso_team_id    = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  organization   = "Organization Name"
  token          = true
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.13.0)

- <a name="requirement_tfe"></a> [tfe](#requirement\_tfe) (~> 0.71)

## Providers

The following providers are used by this module:

- <a name="provider_tfe"></a> [tfe](#provider\_tfe) (~> 0.71)

## Resources

The following resources are used by this module:

- [tfe_team.this](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/team) (resource)
- [tfe_team_access.this](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/team_access) (resource)
- [tfe_team_organization_members.this](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/team_organization_members) (resource)
- [tfe_team_project_access.this](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/team_project_access) (resource)
- [tfe_team_token.this](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/team_token) (resource)

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

Description:   (Optional) Settings for the team's project access.  
    settings : (Optional) The permission to grant for the project's settings. Valid strings: `read`, `update`, or `delete`.  
    teams	   : (Optional) The permission to grant for the project's teams. Valid strings: `none`, `read`, or `manage`.

Type:

```hcl
object({
    settings = optional(string, "read")
    teams    = optional(string, "none")
  })
```

Default: `null`

### <a name="input_custom_workspace_access"></a> [custom\_workspace\_access](#input\_custom\_workspace\_access)

Description:     runs	         : (Optional) The permission to grant project's workspaces' runs. Valid strings: `read`, `plan`, or `apply`.  
    sentinel\_mocks : (Optional) The permission to grant project's workspaces' Sentinel mocks. Valid strings: `none`, or `read`.  
    state\_versions : (Optional) The permission to grant project's workspaces' state versions. Valid strings: `none`, `read-outputs`, `read`, or `write`.  
    variables      : (Optional) The permission to grant project's workspaces' variables. Valid strings: `none`, `read`, or `write`.  
    create         : (Optional) The permission to create project's workspaces in the project.  
    locking        : (Optional) The permission to manually lock or unlock the project's workspaces.  
    delete	       : (Optional) The permission to delete the project's workspaces.  
    move           : (Optional) This permission to move workspaces into and out of the project. The team must also have permissions to the project(s) receiving the the workspace(s).  
    run\_tasks      : (Optional) The permission to manage run tasks within the project's workspaces.

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

Description:   (Optional) Settings for the team's organization access.  
    access\_secret\_teams        : (Optional) Allow members access to secret teams up to the level of permissions granted by their team permissions setting.  
    manage\_agent\_pools         : (Optional) Allow members to create, edit, and delete agent pools within their organization.  
    manage\_membership          : (Optional) Allow members to add/remove users from the organization, and to add/remove users from visible teams.  
    manage\_modules             : (Optional) Allow members to publish and delete modules in the organization's private registry.  
    manage\_organization\_access : (Optional) Allow members to update the organization access settings of teams.  
    manage\_policies            : (Optional) Allows members to create, edit, and delete the organization's Sentinel policies.  
    manage\_policy\_overrides    : (Optional) Allows members to override soft-mandatory policy checks.  
    manage\_projects            : (Optional) Allow members to create and administrate all projects within the organization.  
    manage\_providers           : (Optional) Allow members to publish and delete providers in the organization's private registry.  
    manage\_run\_tasks           : (Optional) Allow members to create, edit, and delete the organization's run tasks.  
    manage\_teams               : (Optional) Allow members to create, update, and delete teams.  
    manage\_vcs\_settings        : (Optional) Allows members to manage the organization's VCS Providers and SSH keys.  
    manage\_workspaces          : (Optional) Allows members to create and administrate all workspaces within the organization.  
    read\_projects              : (Optional) Allow members to view all projects within the organization. Requires read\_workspaces to be set to true.  
    read\_workspaces            : (Optional) Allow members to view all workspaces in this organization.

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

Description: (Required) IDs of organization memberships to be added.

Type: `list(string)`

Default: `[]`

### <a name="input_project_access"></a> [project\_access](#input\_project\_access)

Description: (Optional) Type of fixed access to grant. Valid values are `admin`, `maintain`, `write`, `read`, or `custom`.

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

Description: (Optional) If set to `true`, a team token will be generated.

Type: `bool`

Default: `false`

### <a name="input_token_description"></a> [token\_description](#input\_token\_description)

Description: (Optional) The token's description, which must be unique per team. Required if creating multiple tokens for a single team.

Type: `string`

Default: `null`

### <a name="input_token_expired_at"></a> [token\_expired\_at](#input\_token\_expired\_at)

Description: (Optional) The token's expiration date. The expiration date must be a date/time string in RFC3339 format (e.g., '2024-12-31T23:59:59Z'). If no expiration date is supplied, the expiration date will default to null and never expire.

Type: `string`

Default: `null`

### <a name="input_token_force_regenerate"></a> [token\_force\_regenerate](#input\_token\_force\_regenerate)

Description: (Optional) If set to `true`, a new token will be generated even if a token already exists. This will invalidate the existing token!

Type: `bool`

Default: `false`

### <a name="input_visibility"></a> [visibility](#input\_visibility)

Description: (Optional) The visibility of the team (`secret` or `organization`).

Type: `string`

Default: `"organization"`

### <a name="input_workspace_access"></a> [workspace\_access](#input\_workspace\_access)

Description: (Optional) Type of fixed access to grant. Valid values are `admin`, `read`, `plan`, or `write`. To use custom permissions, use a `workspace_permission` block instead.

Type: `string`

Default: `null`

### <a name="input_workspace_id"></a> [workspace\_id](#input\_workspace\_id)

Description: (Optional) ID of the workspace to which the team will be added.

Type: `string`

Default: `null`

### <a name="input_workspace_permission"></a> [workspace\_permission](#input\_workspace\_permission)

Description:   (Optional) Settings for the team's workspace access.  
      runs              : (Optional) The permission to grant the team on the workspace's runs. Valid values are `read`, `plan`, or `apply`.  
      variables         : (Optional) The permission to grant the team on the workspace's variables. Valid values are `none`, `read`, or `write`.  
      state\_versions    : (Optional) The permission to grant the team on the workspace's state versions. Valid values are `none`, `read`, `read-outputs`, or `write`.  
      sentinel\_mocks    : (Optional) The permission to grant the team on the workspace's generated Sentinel mocks, Valid values are `none` or `read`.  
      workspace\_locking : (Optional) Boolean determining whether or not to grant the team permission to manually lock/unlock the workspace.  
      run\_tasks         : (Optional) Boolean determining whether or not to grant the team permission to manage workspace run tasks.

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

## Outputs

The following outputs are exported:

### <a name="output_team"></a> [team](#output\_team)

Description: HCP Terraform team resource.

### <a name="output_team_id"></a> [team\_id](#output\_team\_id)

Description: The ID of the team.

### <a name="output_token"></a> [token](#output\_token)

Description: The generated token.

### <a name="output_token_id"></a> [token\_id](#output\_token\_id)

Description: The ID of the token.
<!-- END_TF_DOCS -->