output "project" {
  description = "The HCP Terraform project."
  value       = tfe_project.this
}

output "project_id" {
  description = "The ID of the HCP Terraform project."
  value       = tfe_project.this.id
}

output "team_read" {
  description = "The read access team."
  value       = length(module.team_read) > 0 ? module.team_read[0].team : null
}

output "team_read_id" {
  description = "The ID of the read access team."
  value       = length(module.team_read) > 0 ? module.team_read[0].team_id : null
}

output "team_write" {
  description = "The write access team."
  value       = length(module.team_write) > 0 ? module.team_write[0].team : null
}

output "team_write_id" {
  description = "The ID of the write access team."
  value       = length(module.team_write) > 0 ? module.team_write[0].team_id : null
}

output "variable_ids" {
  description = "The IDs of the HCP Terraform variables within the variable set at the project level."
  value       = [for v in tfe_variable.this : v.id]
}

output "variable_set_id" {
  description = "The ID of the HCP Terraform variable set at the project level."
  value       = tfe_variable_set.this.id
}

output "project_variable_set_id" {
  description = "The ID of the tfe_project_variable_set association resource."
  value       = tfe_project_variable_set.this.id
}
