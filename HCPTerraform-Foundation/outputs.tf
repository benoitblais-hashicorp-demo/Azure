output "teams" {
  description = "List of Teams created"
  value       = module.teams[*]
  sensitive   = true
}
