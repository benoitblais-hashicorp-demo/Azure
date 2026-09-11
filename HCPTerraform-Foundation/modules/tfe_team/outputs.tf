output "team" {
  description = "HCP Terraform team resource."
  value       = tfe_team.this
}


output "team_id" {
  description = "The ID of the team."
  value       = tfe_team.this.id
}

output "token" {
  description = "The generated token."
  value       = var.token ? tfe_team_token.this[0].token : null
  sensitive   = true
}

output "token_id" {
  description = "The ID of the token."
  value       = var.token ? tfe_team_token.this[0].id : null
}
