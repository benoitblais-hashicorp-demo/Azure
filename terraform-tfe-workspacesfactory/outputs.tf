output "html_url" {
  description = "The URL to the browsable HTML overview of the workspace."
  value       = tfe_workspace.this.html_url
}

output "workspace_id" {
  description = "The ID of the HCP Terraform workspace."
  value       = tfe_workspace.this.id
}

output "workspace_resource_count" {
  description = "The number of resources managed by the workspace."
  value       = tfe_workspace.this.resource_count
}

output "workspace_run_tasks" {
  description = "The workspace run task resources."
  value       = tfe_workspace_run_task.this
}

output "workspace_run_tasks_ids" {
  description = "A map of run task IDs keyed by task ID."
  value       = { for value in tfe_workspace_run_task.this : value.task_id => value.id }
}
