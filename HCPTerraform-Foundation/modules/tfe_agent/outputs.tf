output "agent_pool_id" {
  description = "he ID of the agent pool."
  value       = tfe_agent_pool.this.id
}

output "agent_token" {
  description = "The agent token."
  value       = { for agent_token in tfe_agent_token.this : agent_token.description => agent_token }
  sensitive   = true
}

output "name" {
  description = "The name of agent pool."
  value       = tfe_agent_pool.this.name
}

output "organization" {
  description = "The name of the organization associated with the agent pool."
  value       = tfe_agent_pool.this.organization
}
