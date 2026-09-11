resource "azuredevops_git_repository" "this" {
  project_id     = var.project_id
  name           = var.name
  default_branch = "refs/heads/${var.default_branch}"
  disabled       = var.disabled

  initialization {
    init_type = var.initialization.init_type
    source_type = var.initialization.source_url != null ? "Git" : null
    source_url  = var.initialization.source_url
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to initialization to support importing existing repositories.
      # Given that a repo now exists, either imported into Terraform state or created by Terraform,
      # we don't care for the configuration of initialization against the existing resource.
      initialization,
    ]
  }
}

resource "azuredevops_branch_policy_min_reviewers" "this" {
  for_each = {
    for bp in var.branch_policies : bp.branch_ref => bp
    if bp.min_reviewers != null
  }

  project_id = var.project_id
  enabled    = each.value.enabled
  blocking   = each.value.blocking

  settings {
    reviewer_count                         = each.value.min_reviewers.reviewer_count
    submitter_can_vote                     = each.value.min_reviewers.submitter_can_vote
    last_pusher_cannot_approve             = each.value.min_reviewers.last_pusher_cannot_approve
    allow_completion_with_rejects_or_waits = each.value.min_reviewers.allow_completion_with_rejects_or_waits
    on_push_reset_approved_votes           = each.value.min_reviewers.on_push_reset_approved_votes
    on_push_reset_all_votes                = each.value.min_reviewers.on_push_reset_all_votes

    scope {
      repository_id  = azuredevops_git_repository.this.id
      repository_ref = each.value.branch_ref
      match_type     = each.value.match_type
    }
  }
}

resource "azuredevops_branch_policy_comment_resolution" "this" {
  for_each = {
    for bp in var.branch_policies : bp.branch_ref => bp
    if bp.require_comment_resolution
  }

  project_id = var.project_id
  enabled    = each.value.enabled
  blocking   = each.value.blocking

  settings {
    scope {
      repository_id  = azuredevops_git_repository.this.id
      repository_ref = each.value.branch_ref
      match_type     = each.value.match_type
    }
  }
}

resource "azuredevops_branch_policy_merge_types" "this" {
  for_each = {
    for bp in var.branch_policies : bp.branch_ref => bp
    if bp.merge_types != null
  }

  project_id = var.project_id
  enabled    = each.value.enabled
  blocking   = each.value.blocking

  settings {
    allow_squash                  = each.value.merge_types.allow_squash
    allow_rebase_and_fast_forward = each.value.merge_types.allow_rebase_and_fast_forward
    allow_basic_no_fast_forward   = each.value.merge_types.allow_basic_no_fast_forward
    allow_rebase_with_merge       = each.value.merge_types.allow_rebase_with_merge

    scope {
      repository_id  = azuredevops_git_repository.this.id
      repository_ref = each.value.branch_ref
      match_type     = each.value.match_type
    }
  }
}

resource "azuredevops_branch_policy_auto_reviewers" "this" {
  for_each = {
    for bp in var.branch_policies : bp.branch_ref => bp
    if bp.auto_reviewers != null
  }

  project_id = var.project_id
  enabled    = each.value.enabled
  blocking   = each.value.blocking

  settings {
    auto_reviewer_ids  = each.value.auto_reviewers.reviewer_ids
    submitter_can_vote = each.value.auto_reviewers.submitter_can_vote
    message            = each.value.auto_reviewers.message
    path_filters       = each.value.auto_reviewers.path_filters

    scope {
      repository_id  = azuredevops_git_repository.this.id
      repository_ref = each.value.branch_ref
      match_type     = each.value.match_type
    }
  }
}
