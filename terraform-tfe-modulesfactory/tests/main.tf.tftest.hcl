# Provider configuration relies entirely on environment variables.
# The azuredevops provider reads:
#   AZDO_ORG_SERVICE_URL          -> https://dev.azure.com/<organization>
#   AZDO_PERSONAL_ACCESS_TOKEN    -> Personal Access Token
# The tfe provider reads:
#   TFE_TOKEN                     -> HCP Terraform API token

provider "azuredevops" {}

provider "tfe" {}

# ─────────────────────────────────────────────────────────────────────────────
# Shared variables required by every run block in this file.
#
# Required variables with no default must be injected via the workspace
# variable set (tfe_test_variable resources provisioned by this module)
# or via environment variables when running tests locally:
#
#   AZDO_ORG_SERVICE_URL              -> https://dev.azure.com/<organization>  (provider env var)
#   AZDO_PERSONAL_ACCESS_TOKEN        -> AzDo PAT                              (provider env var)
#   TFE_TOKEN                         -> HCP Terraform API token               (provider env var)
#   TF_VAR_azuredevops_organization   -> name of the AzDo organization (e.g. ConseilsTI)
#   TF_VAR_azuredevops_project_name   -> name of the AzDo project
#   TF_VAR_oauth_client_name          -> name of the VCS OAuth client (e.g. AzureDevOps)
#   TF_VAR_organization_name          -> HCP Terraform organization name
# ─────────────────────────────────────────────────────────────────────────────

# Only static test-specific values are set here.
# The remaining variables (azuredevops_organization, azuredevops_project_name,
# oauth_client_name, organization_name) are supplied via TF_VAR_* environment
# variables injected automatically by the tfe_test_variable resources this
# module provisions.
variables {
  module_name     = "test"
  module_provider = "azurerm"
}

# ─────────────────────────────────────────────────────────────────────────────
# Run: full apply and verify all key outputs.
# ─────────────────────────────────────────────────────────────────────────────

run "main_passed" {

  command = apply

  # --- repository outputs ---

  assert {
    condition     = output.repository != null
    error_message = "`repository` output should not be null."
  }

  assert {
    condition     = output.repository_id != null && output.repository_id != ""
    error_message = "`repository_id` output should not be empty."
  }

  assert {
    condition     = can(regex("^https://", output.remote_url))
    error_message = "`remote_url` output should start with \"https://\"."
  }

  assert {
    condition     = can(regex("^https://", output.web_url))
    error_message = "`web_url` output should start with \"https://\"."
  }

  assert {
    condition     = can(regex("^refs/heads/", output.default_branch))
    error_message = "`default_branch` output should follow the pattern \"refs/heads/<branch>\"."
  }

  # --- registry module outputs ---

  assert {
    condition     = output.registry_module_id != null && output.registry_module_id != ""
    error_message = "`registry_module_id` output should not be empty."
  }

  assert {
    condition     = output.registry_module_name != null && output.registry_module_name != ""
    error_message = "`registry_module_name` output should not be empty."
  }

  assert {
    condition     = output.registry_module_module_provider != null && output.registry_module_module_provider != ""
    error_message = "`registry_module_module_provider` output should not be empty."
  }

  # --- repository name convention: terraform-<provider>-<name> ---

  assert {
    condition     = can(regex("^terraform-azurerm-test$", output.repository.name))
    error_message = "Repository name should follow the convention \"terraform-<module_provider>-<module_name>\"."
  }

}

# ─────────────────────────────────────────────────────────────────────────────
# Run: verify no-code module is NOT created when no_code_module = false (default).
# ─────────────────────────────────────────────────────────────────────────────

run "main_no_code_module_disabled" {

  command = plan

  variables {
    no_code_module = false
  }

  assert {
    condition     = length(tfe_no_code_module.this) == 0
    error_message = "`tfe_no_code_module` should not be created when `no_code_module` is false."
  }

}

# ─────────────────────────────────────────────────────────────────────────────
# Run: verify the default branch is configurable.
# ─────────────────────────────────────────────────────────────────────────────

run "main_custom_default_branch" {

  command = plan

  variables {
    default_branch = "develop"
  }

  assert {
    condition     = module.repository.default_branch == "refs/heads/develop"
    error_message = "`default_branch` output should reflect the configured branch name."
  }

}
