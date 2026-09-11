resource "azuredevops_git_repository" "this" {
  project_id     = var.project_id
  name           = var.name
  default_branch = "refs/heads/${var.default_branch}"
  disabled       = var.disabled

  initialization {
    init_type   = var.initialization.init_type
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

  depends_on = [azuredevops_git_repository_file.this]

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

  depends_on = [azuredevops_git_repository_file.this]

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

  depends_on = [azuredevops_git_repository_file.this]

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

  depends_on = [azuredevops_git_repository_file.this]

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

# The following resource pushes initial files into the repository after creation.
# Each entry in var.initial_files is committed as a separate file on the default branch.
# This is used to seed new module repositories with scaffold content (e.g. main.tf,
# variables.tf, outputs.tf, versions.tf) so contributors have a starting point.
# Files are only pushed when var.initial_files is non-empty.
#
# IMPORTANT: branch policy resources depend_on this resource so that all files are
# committed before any blocking policy is applied. Without this explicit ordering,
# Terraform may create a branch policy concurrently with the file commits, causing the
# ADO API to reject the push with TF402455 ("Pushes to this branch are not permitted").
#
# content is ignored after the initial create. These files are scaffold — once seeded,
# they belong to the normal PR workflow. Attempting to update them via Terraform would
# fail with TF402455 because the branch policies we create block direct pushes to main.

resource "azuredevops_git_repository_file" "this" {
  for_each = { for f in var.initial_files : f.path => f }

  repository_id       = azuredevops_git_repository.this.id
  file                = each.value.path
  content             = each.value.content
  branch              = "refs/heads/${var.default_branch}"
  commit_message      = "chore: add scaffold file ${each.value.path}"
  overwrite_on_create = true

  lifecycle {
    ignore_changes = [content, commit_message]
  }
}

# The following resources register the three ADO pipelines defined in pipelines/ so that
# they trigger automatically. Pipelines must be registered in ADO — having the YAML file
# in the repository is not sufficient on its own.
#
# Ordering matters:
#   1. merge-pipeline   — runs on every merge to main; pushes a new semver tag
#   2. tag-pipeline     — runs when a semver tag is pushed; publishes to HCP Terraform
#   3. release-pipeline — runs when tag-pipeline completes; archives source as artifact
#
# Pipeline names are prefixed with the repository name (or var.pipeline_name_prefix when
# supplied) so they are unique across the ADO project — all pipelines in a project share
# a flat namespace. Example: "terraform-azurerm-storage-account — tag-pipeline".
#
# release-pipeline.yml carries a resources.pipelines[].source value rendered by templatefile()
# in the parent module; it must match the tag-pipeline name registered here exactly.
#
# All three depend on azuredevops_git_repository_file.this so that the pipeline YAML
# files are present in the repo before ADO tries to validate the registration.

locals {
  pipeline_prefix = var.pipeline_name_prefix != "" ? var.pipeline_name_prefix : var.name
}

resource "azuredevops_build_definition" "merge_pipeline" {
  project_id = var.project_id
  name       = "${local.pipeline_prefix} — merge-pipeline"

  depends_on = [azuredevops_git_repository_file.this]

  # use_yaml = true instructs ADO to read the trigger entirely from the YAML file
  # and never override it. Without this, ADO defaults to "Override YAML CI trigger"
  # with "Disable continuous integration" checked, which silently prevents the pipeline
  # from running after a PR merge.
  ci_trigger {
    use_yaml = true
  }

  repository {
    repo_type   = "TfsGit"
    repo_id     = azuredevops_git_repository.this.id
    branch_name = "refs/heads/${var.default_branch}"
    yml_path    = "pipelines/merge-pipeline.yml"
  }
}

resource "azuredevops_build_definition" "tag_pipeline" {
  project_id = var.project_id
  name       = "${local.pipeline_prefix} — tag-pipeline"

  depends_on = [azuredevops_git_repository_file.this]

  ci_trigger {
    use_yaml = true
  }

  repository {
    repo_type   = "TfsGit"
    repo_id     = azuredevops_git_repository.this.id
    branch_name = "refs/heads/${var.default_branch}"
    yml_path    = "pipelines/tag-pipeline.yml"
  }
}

resource "azuredevops_build_definition" "release_pipeline" {
  project_id = var.project_id
  name       = "${local.pipeline_prefix} — release-pipeline"

  # Must be created after tag-pipeline because release-pipeline.yml references
  # the tag-pipeline by its registered name (rendered into the YAML by templatefile()).
  depends_on = [
    azuredevops_git_repository_file.this,
    azuredevops_build_definition.tag_pipeline,
  ]

  ci_trigger {
    use_yaml = true
  }

  repository {
    repo_type   = "TfsGit"
    repo_id     = azuredevops_git_repository.this.id
    branch_name = "refs/heads/${var.default_branch}"
    yml_path    = "pipelines/release-pipeline.yml"
  }
}
