output "branch_policy_comment_resolution" {
  description = "Map of comment-resolution branch policies keyed by branch ref."
  value       = { for k, v in azuredevops_branch_policy_comment_resolution.this : k => v }
}

output "branch_policy_merge_types" {
  description = "Map of merge-types branch policies keyed by branch ref."
  value       = { for k, v in azuredevops_branch_policy_merge_types.this : k => v }
}

output "branch_policy_min_reviewers" {
  description = "Map of minimum-reviewer branch policies keyed by branch ref."
  value       = { for k, v in azuredevops_branch_policy_min_reviewers.this : k => v }
}

output "default_branch" {
  description = "The ref of the default branch (e.g., `refs/heads/main`)."
  value       = azuredevops_git_repository.this.default_branch
}

output "id" {
  description = "The ID of the Git repository."
  value       = azuredevops_git_repository.this.id
}

output "remote_url" {
  description = "HTTPS clone URL of the repository."
  value       = azuredevops_git_repository.this.remote_url
}

output "repository" {
  description = "Azure DevOps Git repository resource attributes."
  value = {
    id   = azuredevops_git_repository.this.id
    name = azuredevops_git_repository.this.name
  }
}

output "ssh_url" {
  description = "SSH clone URL of the repository."
  value       = azuredevops_git_repository.this.ssh_url
}

output "web_url" {
  description = "Web link to the repository."
  value       = azuredevops_git_repository.this.web_url
}
