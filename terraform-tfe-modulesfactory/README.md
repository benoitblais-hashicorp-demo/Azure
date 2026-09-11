# Modules Factory Terraform Module

Modules Factory module which manages configuration and life-cycle
of your Terraform modules using Azure DevOps as the VCS provider.

## Permissions

### Azure DevOps Permissions

The Azure DevOps provider authenticates via the `AZDO_PERSONAL_ACCESS_TOKEN`
environment variable. The PAT must have:

* **Code** — Read & Write (to create and manage Git repositories)
* **Project and Team** — Read (to look up the project UUID)

### HCP Terraform Permissions

To manage resources, provide a user token from an account with appropriate
permissions. This user should have the `Manage modules` permission.
Alternatively, you can use a token from a team instead of a user token.

## Authentication

### Azure DevOps Authentication

The `azuredevops` provider reads its credentials entirely from environment variables.
No credentials are passed as Terraform variables:

* `AZDO_ORG_SERVICE_URL` — full organization URL, e.g. `https://dev.azure.com/my-org`
* `AZDO_PERSONAL_ACCESS_TOKEN` — Personal Access Token with Code and Project read permissions

### HCP Terraform Authentication

The `tfe` provider reads its token from:

* `TFE_TOKEN` — HCP Terraform API token

## Features

* Create and manage Git repositories within your Azure DevOps project for your Terraform modules.
  * Seed the repository with a standard template by providing a `template_source_url` — the repository is initialized by importing from that Git URL.
  * Push scaffold files into the newly created repository via `initial_files`. The default set includes `.gitignore`, `README.md`, `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`, `tests/`, and the three ADO pipeline definitions (`pipelines/merge-pipeline.yml`, `pipelines/tag-pipeline.yml`, `pipelines/release-pipeline.yml`). Pass an explicit list to override, or `[]` to skip.
  * Configure branch policies (minimum reviewers, comment resolution, merge strategies, auto-reviewers).
* Publish the module inside the private registry of your HCP Terraform organization.
  * Enable the no-code feature when specified.
* Automatically provision `tfe_test_variable` resources so that HCP Terraform module tests
  have access to the required credentials via the workspace variable set.

## Testing

This module ships with a `tests/` folder containing two `tftest.hcl` test suites that run via `terraform test`:

* **`main.tf.tftest.hcl`** — applies the module and validates all key outputs (repository URLs, default branch, registry module ID and name, repository naming convention).
* **`variables.tf.tftest.hcl`** — validates variable contract (invalid `init_type`, missing `source_url` on Import, invalid `match_type`, and `no_code_module` toggle behaviour).

Tests require the following credentials. When run inside HCP Terraform, they are provided automatically by the `tfe_test_variable` resources provisioned by this module. When run locally, export them as environment variables:

```sh
export AZDO_ORG_SERVICE_URL="https://dev.azure.com/<organization>"
export AZDO_PERSONAL_ACCESS_TOKEN="<pat>"
export TFE_TOKEN="<token>"
export TF_VAR_azuredevops_organization="<organization>"
export TF_VAR_azuredevops_project_name="<project>"
export TF_VAR_oauth_client_name="<vcs-oauth-client-name>"
export TF_VAR_organization_name="<hcp-org>"
```

## Usage example

```hcl
module "modulesfactory" {
  source  = "app.terraform.io/<organization_name>/modulesfactory/tfe"
  version = "0.0.0"

  # Identity of the module to publish
  module_name     = "storage-account"
  module_provider = "azurerm"
}
```

To seed the new repository from a template:

```hcl
module "modulesfactory" {
  source  = "app.terraform.io/<organization_name>/modulesfactory/tfe"
  version = "0.0.0"

  module_name          = "storage-account"
  module_provider      = "azurerm"
  template_source_url  = "https://dev.azure.com/MyOrg/MyProject/_git/terraform-module-template"
}
```

## Documentation

## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.13.0)

- <a name="requirement_azuredevops"></a> [azuredevops](#requirement\_azuredevops) (~> 1.16)

- <a name="requirement_tfe"></a> [tfe](#requirement\_tfe) (~> 0.79)

## Modules

The following modules are called by this module:

### <a name="module_repository"></a> [repository](#module\_repository)

Source: `./modules/azuredevops_repository`

Creates and configures the Azure DevOps Git repository and its branch policies.

## Required Inputs

The following input variables are required:

### <a name="input_module_name"></a> [module\_name](#input\_module\_name)

Description: (Required) The name of the Terraform module.

Type: `string`

### <a name="input_module_provider"></a> [module\_provider](#input\_module\_provider)

Description: (Required) The main provider the module uses (e.g., `azurerm`, `aws`).

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_azuredevops_organization"></a> [azuredevops\_organization](#input\_azuredevops\_organization)

Description: (Optional) The name of the Azure DevOps organization. Configured automatically via the project variable set.

Type: `string`

Default: `"placeholder"`

### <a name="input_azuredevops_project_name"></a> [azuredevops\_project\_name](#input\_azuredevops\_project\_name)

Description: (Optional) Name of the Azure DevOps project where the repository will be created. Configured automatically via the project variable set.

Type: `string`

Default: `"placeholder"`

### <a name="input_organization_name"></a> [organization\_name](#input\_organization\_name)

Description: (Optional) Name of the organization. Configured automatically via the project variable set.

Type: `string`

Default: `"placeholder"`

### <a name="input_oauth_client_name"></a> [oauth\_client\_name](#input\_oauth\_client\_name)

Description: (Optional) Name of the OAuth client connecting HCP Terraform to Azure DevOps. Found in HCP Terraform UI: Organization Settings → VCS Providers. Configured automatically via the project variable set.

Type: `string`

Default: `"placeholder"`

### <a name="input_default_branch"></a> [default\_branch](#input\_default\_branch)

Description: (Optional) The short name of the default branch (without the `refs/heads/` prefix). Defaults to `main`.

Type: `string`

Default: `"main"`

### <a name="input_disabled"></a> [disabled](#input\_disabled)

Description: (Optional) Whether the repository is disabled. Defaults to `false`.

Type: `bool`

Default: `false`

### <a name="input_initial_files"></a> [initial\_files](#input\_initial\_files)

Description: (Optional) List of files to commit into the new repository immediately after creation. Each entry requires `path` (relative path, e.g. `main.tf`) and `content` (file content as a string). Defaults to `null`, which causes the module to read all scaffold files from the bundled `template/` directory (`.gitignore`, `README.md`, `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`, `tests/`, and the three ADO pipeline definitions). Set to `[]` to create an empty repository.

Type:

```hcl
list(object({
  path    = string
  content = string
}))
```

Default: `null` (reads all scaffold files from `template/` at plan time via `file()`).

### <a name="input_template_source_url"></a> [template\_source\_url](#input\_template\_source\_url)

Description: (Optional) HTTPS URL of a Git repository to import as the initial content of the new repository. When set, the repository is initialized by cloning from this URL instead of a clean empty init. Useful for seeding new module repositories with a standard template. Defaults to `null` (clean initialization).

Type: `string`

Default: `null`

### <a name="input_initialization"></a> [initialization](#input\_initialization)

Description: (Optional) Low-level repository initialization configuration. Ignored when `template_source_url` is set (which takes precedence and sets `init_type = "Import"` automatically).
  - `init_type` : How to initialize the repository. Valid values: `Clean`, `Uninitialized`, `Import`.
  - `source_url`: URL of the source Git repository when `init_type` is `Import`.

Type:

```hcl
object({
  init_type  = string
  source_url = optional(string, null)
})
```

Default: `{ init_type = "Clean" }`

### <a name="input_no_code_module"></a> [no\_code\_module](#input\_no\_code\_module)

Description: (Optional) Whether this module will be a no-code module.

Type: `bool`

Default: `false`

### <a name="input_branch_policies"></a> [branch\_policies](#input\_branch\_policies)

Description: (Optional) List of branch policy configurations to apply to the repository. Each entry supports: `branch_ref`, `match_type` (`Exact`/`Prefix`/`DefaultBranch`), `enabled`, `blocking`, `require_comment_resolution`, `min_reviewers`, `merge_types`, and `auto_reviewers`.

Type:

```hcl
list(object({
  branch_ref                 = string
  match_type                 = optional(string, "Exact")
  enabled                    = optional(bool, true)
  blocking                   = optional(bool, true)
  require_comment_resolution = optional(bool, false)
  min_reviewers = optional(object({
    reviewer_count                         = number
    submitter_can_vote                     = optional(bool, false)
    last_pusher_cannot_approve             = optional(bool, true)
    allow_completion_with_rejects_or_waits = optional(bool, false)
    on_push_reset_approved_votes           = optional(bool, true)
    on_push_reset_all_votes                = optional(bool, false)
  }), null)
  merge_types = optional(object({
    allow_squash                  = optional(bool, true)
    allow_rebase_and_fast_forward = optional(bool, false)
    allow_basic_no_fast_forward   = optional(bool, true)
    allow_rebase_with_merge       = optional(bool, false)
  }), null)
  auto_reviewers = optional(object({
    reviewer_ids       = list(string)
    submitter_can_vote = optional(bool, false)
    message            = optional(string, null)
    path_filters       = optional(list(string), [])
  }), null)
}))
```

Default: Branch policy on `refs/heads/main` requiring 1 reviewer, comment resolution, and squash/basic merge types.

## Resources

The following resources are used by this module:

- [azuredevops_git_repository.this](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/git_repository) (resource, via `module.repository`) — creates the ADO Git repository
- [azuredevops_git_repository_file.this](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/git_repository_file) (resource, via `module.repository`) — commits scaffold files on repository creation
- [azuredevops_build_definition.merge_pipeline](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/build_definition) (resource, via `module.repository`) — registers the `merge-pipeline` ADO pipeline (bumps semver tag on PR merge)
- [azuredevops_build_definition.tag_pipeline](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/build_definition) (resource, via `module.repository`) — registers the `tag-pipeline` ADO pipeline (publishes module version to HCP Terraform on tag push)
- [azuredevops_build_definition.release_pipeline](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/build_definition) (resource, via `module.repository`) — registers the `release-pipeline` ADO pipeline (archives source artifact after tag-pipeline succeeds)
- [azuredevops_branch_policy_min_reviewers.this](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/branch_policy_min_reviewers) (resource, via `module.repository`) — enforces minimum reviewer count on pull requests
- [azuredevops_branch_policy_comment_resolution.this](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/branch_policy_comment_resolution) (resource, via `module.repository`) — requires all comments to be resolved before merge
- [azuredevops_branch_policy_merge_types.this](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/branch_policy_merge_types) (resource, via `module.repository`) — restricts allowed merge strategies
- [azuredevops_branch_policy_auto_reviewers.this](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/branch_policy_auto_reviewers) (resource, via `module.repository`) — automatically assigns reviewers on pull requests
- [tfe_registry_module.this](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/registry_module) (resource) — publishes the module in the HCP Terraform private registry
- [tfe_no_code_module.this](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/no_code_module) (resource) — enables the no-code deployment feature for the module
- [tfe_test_variable.azdo_org_service_url](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/test_variable) (resource) — `AZDO_ORG_SERVICE_URL` for module test runs
- [tfe_test_variable.azuredevops_organization](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/test_variable) (resource) — `TF_VAR_azuredevops_organization` for module test runs
- [tfe_test_variable.azuredevops_project_name](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/test_variable) (resource) — `TF_VAR_azuredevops_project_name` for module test runs
- [tfe_test_variable.oauth_client_name](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/test_variable) (resource) — `TF_VAR_oauth_client_name` for module test runs
- [tfe_test_variable.organization_name](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/test_variable) (resource) — `TF_VAR_organization_name` for module test runs
- [azuredevops_project.this](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/data-sources/project) (data source) — looks up the ADO project UUID by name
- [tfe_oauth_client.client](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/data-sources/oauth_client) (data source) — retrieves the OAuth token ID for VCS connection

## Outputs

The following outputs are exported:

### <a name="output_repository"></a> [repository](#output\_repository)

Description: Azure DevOps Git repository resource attributes (`id` and `name`).

### <a name="output_repository_id"></a> [repository\_id](#output\_repository\_id)

Description: The ID of the Azure DevOps Git repository.

### <a name="output_remote_url"></a> [remote\_url](#output\_remote\_url)

Description: HTTPS clone URL of the repository.

### <a name="output_ssh_url"></a> [ssh\_url](#output\_ssh\_url)

Description: SSH clone URL of the repository.

### <a name="output_web_url"></a> [web\_url](#output\_web\_url)

Description: Web link to the repository.

### <a name="output_default_branch"></a> [default\_branch](#output\_default\_branch)

Description: The ref of the default branch (e.g., `refs/heads/main`).

### <a name="output_branch_policy_min_reviewers"></a> [branch\_policy\_min\_reviewers](#output\_branch\_policy\_min\_reviewers)

Description: Map of minimum-reviewer branch policies keyed by branch ref.

### <a name="output_branch_policy_comment_resolution"></a> [branch\_policy\_comment\_resolution](#output\_branch\_policy\_comment\_resolution)

Description: Map of comment-resolution branch policies keyed by branch ref.

### <a name="output_branch_policy_merge_types"></a> [branch\_policy\_merge\_types](#output\_branch\_policy\_merge\_types)

Description: Map of merge-types branch policies keyed by branch ref.

### <a name="output_initial_files"></a> [initial\_files](#output\_initial\_files)

Description: Map of scaffold files committed on repository creation, keyed by file path.

### <a name="output_pipelines"></a> [pipelines](#output\_pipelines)

Description: Map of registered ADO pipeline build definitions keyed by name (`merge-pipeline`, `tag-pipeline`, `release-pipeline`).

### <a name="output_registry_module_id"></a> [registry\_module\_id](#output\_registry\_module\_id)

Description: The ID of the registry module.

### <a name="output_registry_module_module_provider"></a> [registry\_module\_module\_provider](#output\_registry\_module\_module\_provider)

Description: The Terraform provider that this module is used for.

### <a name="output_registry_module_name"></a> [registry\_module\_name](#output\_registry\_module\_name)

Description: The name of the registry module.
