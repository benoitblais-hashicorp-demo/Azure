output "repository" {
  description = "Azure DevOps Git repository resource attributes."
  value       = module.repository.repository
}

output "repository_id" {
  description = "The ID of the Azure DevOps Git repository."
  value       = module.repository.id
}

output "remote_url" {
  description = "HTTPS clone URL of the repository."
  value       = module.repository.remote_url
}

output "ssh_url" {
  description = "SSH clone URL of the repository."
  value       = module.repository.ssh_url
}

output "web_url" {
  description = "Web link to the repository."
  value       = module.repository.web_url
}

output "default_branch" {
  description = "The ref of the default branch (e.g., `refs/heads/main`)."
  value       = module.repository.default_branch
}

output "branch_policy_min_reviewers" {
  description = "Map of minimum-reviewer branch policies keyed by branch ref."
  value       = module.repository.branch_policy_min_reviewers
}

output "branch_policy_comment_resolution" {
  description = "Map of comment-resolution branch policies keyed by branch ref."
  value       = module.repository.branch_policy_comment_resolution
}

output "branch_policy_merge_types" {
  description = "Map of merge-types branch policies keyed by branch ref."
  value       = module.repository.branch_policy_merge_types
}

output "initial_files" {
  description = "Map of scaffold files committed on repository creation, keyed by file path."
  value       = module.repository.initial_files
}

output "pipelines" {
  description = "Map of registered ADO pipeline build definitions keyed by name (`merge-pipeline`, `tag-pipeline`, `release-pipeline`)."
  value       = module.repository.pipelines
}

output "registry_module_id" {
  description = "The ID of the registry module."
  value       = tfe_registry_module.this.id
}

output "registry_module_module_provider" {
  description = "The Terraform provider that this module is used for."
  value       = tfe_registry_module.this.module_provider
}

output "registry_module_name" {
  description = "The name of the registry module."
  value       = tfe_registry_module.this.name
}
