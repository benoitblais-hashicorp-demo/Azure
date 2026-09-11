variable "name" {
  description = "(Required) The name of the repository."
  type        = string
  nullable    = false
}

variable "project_id" {
  description = "(Required) The ID or name of the Azure DevOps project in which the repository will be created."
  type        = string
  nullable    = false
}

variable "branch_policies" {
  description = <<EOT
  (Optional) List of branch policy configurations to apply to the repository.
    branch_ref                           : (Required) The fully-qualified branch ref (e.g., `refs/heads/main`).
    match_type                           : (Optional) How to match the ref. Valid values: `Exact`, `Prefix`, `DefaultBranch`. Defaults to `Exact`.
    enabled                              : (Optional) Whether all policies in this block are enabled. Defaults to `true`.
    blocking                             : (Optional) Whether all policies in this block are blocking. Defaults to `true`.
    require_comment_resolution           : (Optional) Enable the comment resolution policy. Defaults to `false`.
    min_reviewers                        : (Optional) Minimum reviewer count policy. Omit to skip.
      reviewer_count                     : (Required) Number of required approvals.
      submitter_can_vote                 : (Optional) Allow requesters to approve their own changes. Defaults to `false`.
      last_pusher_cannot_approve         : (Optional) Prohibit the most recent pusher from approving. Defaults to `true`.
      allow_completion_with_rejects_or_waits : (Optional) Allow completion even with rejections. Defaults to `false`.
      on_push_reset_approved_votes       : (Optional) Reset approved votes on new push. Defaults to `true`.
      on_push_reset_all_votes            : (Optional) Reset all votes on new push. Defaults to `false`.
    merge_types                          : (Optional) Merge strategies policy. Omit to skip.
      allow_squash                       : (Optional) Allow squash merge. Defaults to `true`.
      allow_rebase_and_fast_forward      : (Optional) Allow rebase with fast-forward. Defaults to `false`.
      allow_basic_no_fast_forward        : (Optional) Allow basic merge (no fast-forward). Defaults to `true`.
      allow_rebase_with_merge            : (Optional) Allow rebase with merge commit. Defaults to `false`.
    auto_reviewers                       : (Optional) Automatically added reviewers policy. Omit to skip.
      reviewer_ids                       : (Required) List of Azure DevOps user/group object IDs to add as reviewers.
      submitter_can_vote                 : (Optional) Allow the submitter to vote. Defaults to `false`.
      message                            : (Optional) Activity-feed message shown when reviewers are added.
      path_filters                       : (Optional) List of path patterns to scope the policy (e.g., `/src/*`).
  EOT
  type = list(object({
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
  nullable = false
  default = [
    {
      branch_ref                 = "refs/heads/main"
      match_type                 = "Exact"
      enabled                    = true
      blocking                   = true
      require_comment_resolution = true
      min_reviewers = {
        reviewer_count                         = 1
        submitter_can_vote                     = false
        last_pusher_cannot_approve             = true
        allow_completion_with_rejects_or_waits = false
        on_push_reset_approved_votes           = true
        on_push_reset_all_votes                = false
      }
      merge_types = {
        allow_squash                  = true
        allow_rebase_and_fast_forward = false
        allow_basic_no_fast_forward   = true
        allow_rebase_with_merge       = false
      }
    }
  ]

  validation {
    condition     = alltrue([for bp in var.branch_policies : contains(["Exact", "Prefix", "DefaultBranch"], bp.match_type)])
    error_message = "Valid values for `match_type` are \"Exact\", \"Prefix\", or \"DefaultBranch\"."
  }
}

variable "default_branch" {
  description = "(Optional) The short name of the default branch (without the `refs/heads/` prefix). Defaults to `main`."
  type        = string
  nullable    = false
  default     = "main"
}

variable "disabled" {
  description = "(Optional) Whether the repository is disabled. Defaults to `false`."
  type        = bool
  default     = false
}

variable "initialization" {
  description = <<EOT
  (Required) Repository initialization configuration:
    init_type  : (Required) How to initialize the repository. Valid values: `Clean`, `Uninitialized`, `Import`.
    source_url : (Optional) URL of the source Git repository when `init_type` is `Import`.
  EOT
  type = object({
    init_type  = string
    source_url = optional(string, null)
  })
  default = {
    init_type  = "Clean"
    source_url = null
  }

  validation {
    condition     = contains(["Clean", "Uninitialized", "Import"], var.initialization.init_type)
    error_message = "Valid values for `init_type` are \"Clean\", \"Uninitialized\", or \"Import\"."
  }
  validation {
    condition     = var.initialization.init_type == "Import" ? var.initialization.source_url != null : true
    error_message = "`source_url` is required when `init_type` is \"Import\"."
  }
}
