output "html_url" {
  description = "The URL to the browsable HTML overview of the workspace."
  value       = tfe_workspace.this.html_url
}

output "id" {
  description = "The workspace ID."
  value       = tfe_workspace.this.id
}

output "resource_count" {
  description = "The number of resources managed by the workspace."
  value       = tfe_workspace.this.resource_count
}

output "workspace" {
  description = "Terraform Cloud workspace resource."
  value = {
    id          = tfe_workspace.this.id
    name        = tfe_workspace.this.name
    description = tfe_workspace.this.description
  }
}

output "workspace_run_tasks" {
  description = "The workspace run tasks."
  value       = tfe_workspace_run_task.this
}

output "workspace_run_tasks_id" {
  description = "The workspace run tasks id."
  value       = { for value in tfe_workspace_run_task.this : value.task_id => value.id }
}