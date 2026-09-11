# Workspaces Factory Terraform Module

Workspaces Factory module which manages configuration and life-cycle
of your Terraform workspaces.

## Permissions

### HCP Terraform Permissions

To manage resources, provide a user token from an account with
appropriate permissions. This user should have the `Manage Projects` and `Manage Workspaces`
permission. Alternatively, you can use a token from a team instead of a user token.

## Authentication

### HCP Terraform Authentication

The HCP Terraform provider requires a HCP Terraform/Terraform Enterprise API token in
order to manage resources.

There are several ways to provide the required token:

* Set the `TFE_TOKEN` environment variable. The provider can read the `TFE_TOKEN` environment variable and the token stored there to authenticate.

## Features

* Manages configuration and life-cycle of HCP Terraform resources:
  * Workspace
  * Workspace settings (execution mode, remote state)
  * Workspace run tasks
  * Workspace variables

## Usage example

```hcl
module "workspace" {
  source  = "app.terraform.io/<organization_name>/workspacesfactory/tfe"
  version = "0.0.0"

  name                     = "my-workspace"
  project_name             = "my-project"
  vcs_repo_name            = "my-repo"

  # The following are injected automatically via the HCPTerraform-WorkspacesFactory variable set:
  # organization_name        = "my-hcp-org"
  # azuredevops_organization = "my-azdo-org"
  # azuredevops_project_name = "My AzDO Project"   # spaces are URL-encoded automatically
}
```

## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.13.0)

- <a name="requirement_tfe"></a> [tfe](#requirement\_tfe) (~> 0.79)

## Modules

No modules.

## Required Inputs

The following input variables are required:

### <a name="input_name"></a> [name](#input\_name)

Description: (Required) Name of the workspace.

Type: `string`

### <a name="input_project_name"></a> [project\_name](#input\_project\_name)

Description: (Required) Name of the project where the workspace should be created.

Type: `string`

### <a name="input_vcs_repo_name"></a> [vcs\_repo\_name](#input\_vcs\_repo\_name)

Description: (Required) Name of the Azure DevOps repository. Used together with `azuredevops_organization` and `azuredevops_project_name` to build the VCS identifier automatically.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_azuredevops_organization"></a> [azuredevops\_organization](#input\_azuredevops\_organization)

Description: (Optional) The name of the Azure DevOps organization (the segment after `dev.azure.com/` in the URL). Used together with `azuredevops_project_name` and `vcs_repo_name` to build the VCS identifier. Configured automatically via the project variable set.

Type: `string`

Default: `null`

### <a name="input_azuredevops_project_name"></a> [azuredevops\_project\_name](#input\_azuredevops\_project\_name)

Description: (Optional) The name of the Azure DevOps project where the repository lives. Spaces are URL-encoded automatically when building the VCS identifier. Configured automatically via the project variable set.

Type: `string`

Default: `null`

### <a name="input_agent_pool_id"></a> [agent\_pool\_id](#input\_agent\_pool\_id)

Description: (Optional) The ID of an agent pool to assign to the workspace. Requires `execution_mode` to be set to `agent`. This value must not be provided if `execution_mode` is set to any other value.

Type: `string`

Default: `null`

### <a name="input_allow_destroy_plan"></a> [allow\_destroy\_plan](#input\_allow\_destroy\_plan)

Description: (Optional) Whether destroy plans can be queued on the workspace.

Type: `bool`

Default: `true`

### <a name="input_assessments_enabled"></a> [assessments\_enabled](#input\_assessments\_enabled)

Description: (Optional) Whether to regularly run health assessments such as drift detection on the workspace.

Type: `bool`

Default: `false`

### <a name="input_auto_apply"></a> [auto\_apply](#input\_auto\_apply)

Description: (Optional) Whether to automatically apply changes when a Terraform plan is successful.

Type: `bool`

Default: `true`

### <a name="input_auto_apply_run_trigger"></a> [auto\_apply\_run\_trigger](#input\_auto\_apply\_run\_trigger)

Description: (Optional) Whether to automatically apply changes for runs that were created by run triggers from another workspace.

Type: `bool`

Default: `true`

### <a name="input_description"></a> [description](#input\_description)

Description: (Optional) A description for the workspace.

Type: `string`

Default: `null`

### <a name="input_execution_mode"></a> [execution\_mode](#input\_execution\_mode)

Description: (Optional) Which execution mode to use. Valid values are `remote`, `local` or `agent`. When set to `local`, the workspace will be used for state storage only. If omitted, the workspace uses the organization's default execution mode.

Type: `string`

Default: `null`

### <a name="input_file_triggers_enabled"></a> [file\_triggers\_enabled](#input\_file\_triggers\_enabled)

Description: (Optional) Whether to filter runs based on the changed files in a VCS push. If enabled, the working directory and trigger prefixes describe a set of paths which must contain changes for a VCS push to trigger a run. If disabled, any push will trigger a run.

Type: `bool`

Default: `true`

### <a name="input_global_remote_state"></a> [global\_remote\_state](#input\_global\_remote\_state)

Description: (Optional) Whether the workspace allows all workspaces in the organization to access its state data during runs. If false, then only specifically approved workspaces can access its state (`remote_state_consumer_ids`).

Type: `bool`

Default: `false`

### <a name="input_organization_name"></a> [organization\_name](#input\_organization\_name)

Description: (Optional) Name of the HCP Terraform organization. Configured automatically via the project variable set.

Type: `string`

Default: `null`

### <a name="input_queue_all_runs"></a> [queue\_all\_runs](#input\_queue\_all\_runs)

Description: (Optional) Whether the workspace should start automatically performing runs immediately after its creation. When set to `false`, runs triggered by a webhook (such as a commit in VCS) will not be queued until at least one run has been manually queued.

Type: `bool`

Default: `true`

### <a name="input_remote_state_consumer_ids"></a> [remote\_state\_consumer\_ids](#input\_remote\_state\_consumer\_ids)

Description: (Optional) The set of workspace IDs set as explicit remote state consumers for the given workspace.

Type: `set(string)`

Default: `[]`

### <a name="input_run_tasks"></a> [run\_tasks](#input\_run\_tasks)

Description: (Optional) A list of run tasks to be executed on the workspace.
  - `task_id`           : (Required) The id of the Run task to associate to the workspace.
  - `enforcement_level` : (Optional) The enforcement level of the task. Valid values are `advisory` and `mandatory`.
  - `stages`            : (Optional) The stages to run the task in. Valid values are `pre_plan`, `post_plan`, `pre_apply` and `post_apply`.

Type:

```hcl
list(object({
  task_id           = string
  enforcement_level = optional(string, "advisory")
  stages            = optional(list(string), [])
}))
```

Default: `[]`

### <a name="input_source_name"></a> [source\_name](#input\_source\_name)

Description: (Optional) A friendly name for the application or client creating this workspace. If set, this will be displayed on the workspace as 'Created via <source_name>'. Requires `source_url` to also be set.

Type: `string`

Default: `null`

### <a name="input_source_url"></a> [source\_url](#input\_source\_url)

Description: (Optional) A URL for the application or client creating this workspace. Requires `source_name` to also be set. Note: cannot be updated after workspace creation — modifying this value will replace the workspace.

Type: `string`

Default: `null`

### <a name="input_speculative_enabled"></a> [speculative\_enabled](#input\_speculative\_enabled)

Description: (Optional) Whether this workspace allows speculative plans. Setting this to `false` prevents Terraform Cloud or the Terraform Enterprise instance from running plans on pull requests.

Type: `bool`

Default: `true`

### <a name="input_ssh_key_id"></a> [ssh\_key\_id](#input\_ssh\_key\_id)

Description: (Optional) The ID of an SSH key to assign to the workspace.

Type: `string`

Default: `null`

### <a name="input_structured_run_output_enabled"></a> [structured\_run\_output\_enabled](#input\_structured\_run\_output\_enabled)

Description: (Optional) Whether this workspace should show output from Terraform runs using the enhanced UI when available. Setting this to `false` ensures that all runs in this workspace will display their output as text logs.

Type: `bool`

Default: `false`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: (Optional) A map of key-value tags for this workspace.

Type: `map(string)`

Default: `null`

### <a name="input_terraform_version"></a> [terraform\_version](#input\_terraform\_version)

Description: (Optional) The version of Terraform to use for this workspace. This can be either an exact version or a version constraint (like `~> 1.0.0`). Defaults to `latest`.

Type: `string`

Default: `"latest"`

### <a name="input_trigger_patterns"></a> [trigger\_patterns](#input\_trigger\_patterns)

Description: (Optional) List of glob patterns that describe the files Terraform Cloud monitors for changes. Trigger patterns are always appended to the root directory of the repository. Mutually exclusive with `trigger_prefixes`.

Type: `list(string)`

Default:

```json
[
  "*.tf"
]
```

### <a name="input_trigger_prefixes"></a> [trigger\_prefixes](#input\_trigger\_prefixes)

Description: (Optional) List of repository-root-relative paths which describe all locations to be tracked for changes. Mutually exclusive with `trigger_patterns`.

Type: `list(string)`

Default: `null`

### <a name="input_variables"></a> [variables](#input\_variables)

Description: (Optional) List of variables to add to the workspace.
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

### <a name="input_vcs_repo_branch"></a> [vcs\_repo\_branch](#input\_vcs\_repo\_branch)

Description: (Optional) The repository branch that Terraform will execute from. This defaults to the repository's default branch (e.g. main).

Type: `string`

Default: `null`

### <a name="input_vcs_repo_github_app_installation_id"></a> [vcs\_repo\_github\_app\_installation\_id](#input\_vcs\_repo\_github\_app\_installation\_id)

Description: (Optional) The installation id of the GitHub App. Conflicts with `vcs_repo_oauth_token_id`.

Type: `string`

Default: `null`

### <a name="input_vcs_repo_ingress_submodules"></a> [vcs\_repo\_ingress\_submodules](#input\_vcs\_repo\_ingress\_submodules)

Description: (Optional) Whether submodules should be fetched when cloning the VCS repository.

Type: `bool`

Default: `false`

### <a name="input_vcs_repo_oauth_token_id"></a> [vcs\_repo\_oauth\_token\_id](#input\_vcs\_repo\_oauth\_token\_id)

Description: (Optional) The VCS Connection OAuth Token ID used to authenticate with Azure DevOps. Injected automatically via the project variable set configured by HCPTerraform-WorkspacesFactory.

Type: `string`

Default: `null`

### <a name="input_vcs_repo_identifier"></a> [vcs\_repo\_identifier](#input\_vcs\_repo\_identifier)

Description: (Optional) Override for the full VCS identifier passed to HCP Terraform. Use this only when `vcs_repo_name`, `azuredevops_organization`, and `azuredevops_project_name` are not sufficient. For Azure DevOps the format is `<org>/<project%20url-encoded>/_git/<repo>`. When set, this takes precedence over the automatically built identifier.

Type: `string`

Default: `null`

### <a name="input_vcs_repo_tags_regex"></a> [vcs\_repo\_tags\_regex](#input\_vcs\_repo\_tags\_regex)

Description: (Optional) A regular expression used to trigger a workspace run for matching Git tags. Conflicts with `trigger_patterns` and `trigger_prefixes`.

Type: `string`

Default: `null`

### <a name="input_working_directory"></a> [working\_directory](#input\_working\_directory)

Description: (Optional) A relative path that Terraform will execute within. Defaults to the root of your repository.

Type: `string`

Default: `null`

## Resources

The following resources are used by this module:

- [tfe_workspace.this](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/workspace) (resource) — HCP Terraform workspace
- [tfe_workspace_settings.this](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/workspace_settings) (resource) — workspace execution mode and remote state settings
- [tfe_workspace_run_task.this](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/workspace_run_task) (resource) — run tasks attached to the workspace
- [tfe_variable.this](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable) (resource) — workspace-level variables
- [tfe_project.this](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/data-sources/project) (data source) — looks up the project by name to resolve its ID

## Outputs

The following outputs are exported:

### <a name="output_html_url"></a> [html\_url](#output\_html\_url)

Description: The URL to the browsable HTML overview of the workspace.

### <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id)

Description: The ID of the HCP Terraform workspace.

### <a name="output_workspace_resource_count"></a> [workspace\_resource\_count](#output\_workspace\_resource\_count)

Description: The number of resources managed by the workspace.

### <a name="output_workspace_run_tasks"></a> [workspace\_run\_tasks](#output\_workspace\_run\_tasks)

Description: The workspace run task resources.

### <a name="output_workspace_run_tasks_ids"></a> [workspace\_run\_tasks\_ids](#output\_workspace\_run\_tasks\_ids)

Description: A map of run task IDs keyed by task ID.
