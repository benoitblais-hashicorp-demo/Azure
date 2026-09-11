# Azure DevOps repository Terraform module

Azure DevOps repository module which manages configuration and life-cycle
of your Azure DevOps Git repository, including branch policies.

## Permissions

To manage the Azure DevOps resources, provide a Personal Access Token (PAT)
from an account with appropriate permissions. The PAT should have:

* **Code**: Read, Create & Manage

## Authentication

The Azure DevOps provider requires either a Personal Access Token or a
Service Principal in order to manage resources.

There are several ways to provide the required token:

- Set the `personal_access_token` argument in the provider configuration.
  Use an input variable for the token.
- Set the `AZDO_PERSONAL_ACCESS_TOKEN` environment variable. The provider
  can read the `AZDO_PERSONAL_ACCESS_TOKEN` environment variable and the
  token stored there to authenticate.

The organization URL is also required:

- Set the `org_service_url` argument in the provider configuration.
- Set the `AZDO_ORG_SERVICE_URL` environment variable.

## Features

- Create and manage Git repositories within an Azure DevOps project.
- Configure branch policies per branch:
  - **Minimum reviewers** — required approving review count, stale-vote
    reset on push, and last-pusher approval restriction.
  - **Comment resolution** — all PR comments must be resolved before merge.
  - **Merge types** — restrict which merge strategies are permitted.
  - **Auto reviewers** — automatically add reviewers based on path filters.

## Usage example

```hcl
module "repository" {
  source = "./modules/azuredevops_repository"

  project_id = "00000000-0000-0000-0000-000000000000"
  name       = "terraform-azuredevops-mymodule"

  branch_policies = [
    {
      branch_ref                 = "refs/heads/main"
      require_comment_resolution = true
      min_reviewers = {
        reviewer_count = 1
      }
      merge_types = {
        allow_squash            = true
        allow_basic_no_fast_forward = true
      }
    }
  ]
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.13.0)

- <a name="requirement_azuredevops"></a> [azuredevops](#requirement\_azuredevops) (~> 1.16)

## Providers

The following providers are used by this module:

- <a name="provider_azuredevops"></a> [azuredevops](#provider\_azuredevops) (~> 1.16)

## Resources

The following resources are used by this module:

- [azuredevops_git_repository.this](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/git_repository) (resource)
- [azuredevops_branch_policy_min_reviewers.this](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/branch_policy_min_reviewers) (resource)
- [azuredevops_branch_policy_comment_resolution.this](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/branch_policy_comment_resolution) (resource)
- [azuredevops_branch_policy_merge_types.this](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/branch_policy_merge_types) (resource)
- [azuredevops_branch_policy_auto_reviewers.this](https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/branch_policy_auto_reviewers) (resource)

## Required Inputs

The following input variables are required:

### <a name="input_name"></a> [name](#input\_name)

Description: (Required) The name of the repository.

Type: `string`

### <a name="input_project_id"></a> [project\_id](#input\_project\_id)

Description: (Required) The ID or name of the Azure DevOps project in which the repository will be created.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_branch_policies"></a> [branch\_policies](#input\_branch\_policies)

Description: (Optional) List of branch policy configurations to apply to the repository.
- `branch_ref` : (Required) The fully-qualified branch ref (e.g., `"refs/heads/main"`).
- `match_type` : (Optional) How to match the ref. Valid values: `Exact`, `Prefix`, `DefaultBranch`. Defaults to `Exact`.
- `enabled` : (Optional) Whether all policies in this block are enabled. Defaults to `true`.
- `blocking` : (Optional) Whether all policies in this block are blocking. Defaults to `true`.
- `require_comment_resolution` : (Optional) Enable the comment resolution policy. Defaults to `false`.
- `min_reviewers` : (Optional) Minimum reviewer count policy. Omit to skip.
  - `reviewer_count` : (Required) Number of required approvals.
  - `submitter_can_vote` : (Optional) Allow requesters to approve their own changes. Defaults to `false`.
  - `last_pusher_cannot_approve` : (Optional) Prohibit the most recent pusher from approving. Defaults to `true`.
  - `allow_completion_with_rejects_or_waits` : (Optional) Allow completion even with rejections. Defaults to `false`.
  - `on_push_reset_approved_votes` : (Optional) Reset approved votes on new push. Defaults to `true`.
  - `on_push_reset_all_votes` : (Optional) Reset all votes on new push. Defaults to `false`.
- `merge_types` : (Optional) Merge strategies policy. Omit to skip.
  - `allow_squash` : (Optional) Allow squash merge. Defaults to `true`.
  - `allow_rebase_and_fast_forward` : (Optional) Allow rebase with fast-forward. Defaults to `false`.
  - `allow_basic_no_fast_forward` : (Optional) Allow basic merge (no fast-forward). Defaults to `true`.
  - `allow_rebase_with_merge` : (Optional) Allow rebase with merge commit. Defaults to `false`.
- `auto_reviewers` : (Optional) Automatically added reviewers policy. Omit to skip.
  - `reviewer_ids` : (Required) List of Azure DevOps user/group object IDs to add as reviewers.
  - `submitter_can_vote` : (Optional) Allow the submitter to vote. Defaults to `false`.
  - `message` : (Optional) Activity-feed message shown when reviewers are added.
  - `path_filters` : (Optional) List of path patterns to scope the policy (e.g., `/src/*`).

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

Default: See `variables.tf` for full default value.

### <a name="input_default_branch"></a> [default\_branch](#input\_default\_branch)

Description: (Optional) The short name of the default branch (without the `refs/heads/` prefix). Defaults to `main`.

Type: `string`

Default: `"main"`

### <a name="input_disabled"></a> [disabled](#input\_disabled)

Description: (Optional) Whether the repository is disabled. Defaults to `false`.

Type: `bool`

Default: `false`

### <a name="input_initialization"></a> [initialization](#input\_initialization)

Description: (Required) Repository initialization configuration. `init_type` valid values: `Clean`, `Uninitialized`, `Import`. `source_url` is required when `init_type` is `Import`.

Type:

```hcl
object({
  init_type  = string
  source_url = optional(string, null)
})
```

Default: `{ init_type = "Clean" }`

## Outputs

The following outputs are exported:

### <a name="output_repository"></a> [repository](#output\_repository)

Description: Azure DevOps Git repository resource attributes (`id`, `name`).

### <a name="output_id"></a> [id](#output\_id)

Description: The ID of the Git repository.

### <a name="output_default_branch"></a> [default\_branch](#output\_default\_branch)

Description: The ref of the default branch (e.g., `refs/heads/main`).

### <a name="output_remote_url"></a> [remote\_url](#output\_remote\_url)

Description: HTTPS clone URL of the repository.

### <a name="output_ssh_url"></a> [ssh\_url](#output\_ssh\_url)

Description: SSH clone URL of the repository.

### <a name="output_web_url"></a> [web\_url](#output\_web\_url)

Description: Web link to the repository.

### <a name="output_branch_policy_min_reviewers"></a> [branch\_policy\_min\_reviewers](#output\_branch\_policy\_min\_reviewers)

Description: Map of minimum-reviewer branch policies keyed by branch ref.

### <a name="output_branch_policy_comment_resolution"></a> [branch\_policy\_comment\_resolution](#output\_branch\_policy\_comment\_resolution)

Description: Map of comment-resolution branch policies keyed by branch ref.

### <a name="output_branch_policy_merge_types"></a> [branch\_policy\_merge\_types](#output\_branch\_policy\_merge\_types)

Description: Map of merge-types branch policies keyed by branch ref.
<!-- END_TF_DOCS -->
