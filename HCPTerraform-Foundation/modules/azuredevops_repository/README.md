# Azure DevOps Repository Terraform module

Azure DevOps Repository module which manages configuration and life-cycle of
your Azure DevOps Git repositories and branch policies.

## Permissions

To manage the repository resources, provide a Personal Access Token (PAT) or
service principal with appropriate permissions. The identity must have:

- **Code**: Read & Write (to create and configure repositories)
- **Project and Team**: Read (to read project information)
- **Build**: Read & Execute (required for branch policies that reference build definitions)

## Authentication

The Azure DevOps provider requires a Personal Access Token (PAT) or service principal
credentials in order to manage resources.

There are several ways to provide the required credentials:

- Set the `AZDO_ORG_SERVICE_URL` environment variable to your Azure DevOps organization URL
  (e.g., `https://dev.azure.com/your-org`).
- Set the `AZDO_PERSONAL_ACCESS_TOKEN` environment variable to authenticate with a PAT.

## Features

- Create and manage Azure DevOps Git repositories.
- Enforce minimum reviewer count branch policies.
- Enforce comment resolution branch policies.
- Enforce merge strategy branch policies.
- Enforce auto-reviewer branch policies.

## Usage example
```hcl
module "repository" {
  source     = "./modules/azuredevops_repository"

  name       = "my-repository"
  project_id = data.azuredevops_project.this.id  # Must be a UUID — use azuredevops_project data source to look up from a name
}
```

## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.13.0)

- <a name="requirement_azuredevops"></a> [azuredevops](#requirement\_azuredevops) (~> 1.16)

## Providers

The following providers are used by this module:

- <a name="provider_azuredevops"></a> [azuredevops](#provider\_azuredevops) (~> 1.16)

## Modules

No modules.

## Resources

The following resources are used by this module:

- [azuredevops_git_repository.this](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/git_repository) (resource)
- [azuredevops_branch_policy_auto_reviewers.this](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/branch_policy_auto_reviewers) (resource)
- [azuredevops_branch_policy_comment_resolution.this](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/branch_policy_comment_resolution) (resource)
- [azuredevops_branch_policy_merge_types.this](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/branch_policy_merge_types) (resource)
- [azuredevops_branch_policy_min_reviewers.this](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/branch_policy_min_reviewers) (resource)

## Required Inputs

The following input variables are required:

### <a name="input_name"></a> [name](#input\_name)

Description: (Required) The name of the repository.

Type: `string`

### <a name="input_project_id"></a> [project\_id](#input\_project\_id)

Description: (Required) The UUID of the Azure DevOps project in which the repository will be created. Must be a UUID — use the `azuredevops_project` data source to resolve a project name to its UUID.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_branch_policies"></a> [branch\_policies](#input\_branch\_policies)

Description: (Optional) List of branch policy configurations to apply to the repository.

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

Default: protection on `refs/heads/main` with comment resolution, 1 required reviewer, and squash + no-fast-forward merge strategies enabled.

### <a name="input_default_branch"></a> [default\_branch](#input\_default\_branch)

Description: (Optional) The short name of the default branch (without the `refs/heads/` prefix). Defaults to `main`.

Type: `string`

Default: `"main"`

### <a name="input_disabled"></a> [disabled](#input\_disabled)

Description: (Optional) Whether the repository is disabled. Defaults to `false`.

Type: `bool`

Default: `false`

### <a name="input_initialization"></a> [initialization](#input\_initialization)

Description: (Optional) Repository initialization configuration.  
  init\_type  : (Required) How to initialize the repository. Valid values: `Clean`, `Uninitialized`, `Import`.  
  source\_url : (Optional) URL of the source Git repository when `init_type` is `Import`.

Type:

```hcl
object({
    init_type  = string
    source_url = optional(string, null)
  })
```

Default: `{ init_type = "Clean", source_url = null }`

## Outputs

The following outputs are exported:

### <a name="output_branch_policy_comment_resolution"></a> [branch\_policy\_comment\_resolution](#output\_branch\_policy\_comment\_resolution)

Description: Map of comment-resolution branch policies keyed by branch ref.

### <a name="output_branch_policy_merge_types"></a> [branch\_policy\_merge\_types](#output\_branch\_policy\_merge\_types)

Description: Map of merge-types branch policies keyed by branch ref.

### <a name="output_branch_policy_min_reviewers"></a> [branch\_policy\_min\_reviewers](#output\_branch\_policy\_min\_reviewers)

Description: Map of minimum-reviewer branch policies keyed by branch ref.

### <a name="output_default_branch"></a> [default\_branch](#output\_default\_branch)

Description: The ref of the default branch (e.g., `refs/heads/main`).

### <a name="output_id"></a> [id](#output\_id)

Description: The ID of the Git repository.

### <a name="output_remote_url"></a> [remote\_url](#output\_remote\_url)

Description: HTTPS clone URL of the repository.

### <a name="output_repository"></a> [repository](#output\_repository)

Description: Azure DevOps Git repository resource attributes.

### <a name="output_ssh_url"></a> [ssh\_url](#output\_ssh\_url)

Description: SSH clone URL of the repository.

### <a name="output_web_url"></a> [web\_url](#output\_web\_url)

Description: Web link to the repository.
