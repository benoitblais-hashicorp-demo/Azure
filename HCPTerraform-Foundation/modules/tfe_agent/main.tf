resource "tfe_agent_pool" "this" {
  name                = var.name
  organization        = var.organization
  organization_scoped = var.organization_scoped
}

resource "tfe_agent_token" "this" {
  for_each      = toset(var.token_description)
  agent_pool_id = tfe_agent_pool.this.id
  description   = each.key
}
