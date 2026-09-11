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
# Tests: var.initialization -- invalid init_type value
# ─────────────────────────────────────────────────────────────────────────────

run "variables_initialization_invalid_init_type" {

  command = plan

  variables {
    initialization = {
      init_type  = "BadType"
      source_url = null
    }
  }

  expect_failures = [
    var.initialization,
  ]

}

# ─────────────────────────────────────────────────────────────────────────────
# Tests: var.initialization -- Import without source_url
# ─────────────────────────────────────────────────────────────────────────────

run "variables_initialization_import_missing_source_url" {

  command = plan

  variables {
    initialization = {
      init_type  = "Import"
      source_url = null
    }
  }

  expect_failures = [
    var.initialization,
  ]

}

# ─────────────────────────────────────────────────────────────────────────────
# Tests: var.branch_policies -- invalid match_type value
# ─────────────────────────────────────────────────────────────────────────────

run "variables_branch_policies_invalid_match_type" {

  command = plan

  variables {
    branch_policies = [
      {
        branch_ref = "refs/heads/main"
        match_type = "InvalidMatchType"
      }
    ]
  }

  expect_failures = [
    var.branch_policies,
  ]

}

# ─────────────────────────────────────────────────────────────────────────────
# Tests: var.default_branch -- verify a non-default value passes validation
# ─────────────────────────────────────────────────────────────────────────────

run "variables_default_branch_custom_value" {

  command = plan

  variables {
    default_branch = "develop"
  }

  assert {
    condition     = module.repository.default_branch == "refs/heads/develop"
    error_message = "`default_branch` should produce a `refs/heads/develop` ref."
  }

}

# ─────────────────────────────────────────────────────────────────────────────
# Tests: var.no_code_module = true -- verify tfe_no_code_module is planned
# ─────────────────────────────────────────────────────────────────────────────

run "variables_no_code_module_enabled" {

  command = plan

  variables {
    no_code_module = true
  }

  assert {
    condition     = length(tfe_no_code_module.this) == 1
    error_message = "`tfe_no_code_module` should be planned when `no_code_module` is true."
  }

}

# ─────────────────────────────────────────────────────────────────────────────
# Tests: var.branch_policies -- verify default policy targets refs/heads/main
# ─────────────────────────────────────────────────────────────────────────────

run "variables_branch_policies_default_targets_main" {

  command = plan

  assert {
    condition     = var.branch_policies[0].branch_ref == "refs/heads/main"
    error_message = "The default branch policy should target \"refs/heads/main\"."
  }

}

# ─────────────────────────────────────────────────────────────────────────────
# Tests: var.branch_policies -- valid match_type values pass validation
# ─────────────────────────────────────────────────────────────────────────────

run "variables_branch_policies_valid_match_types" {

  command = plan

  variables {
    branch_policies = [
      {
        branch_ref = "refs/heads/main"
        match_type = "Exact"
      },
      {
        branch_ref = "refs/heads/release/"
        match_type = "Prefix"
      },
      {
        branch_ref = ""
        match_type = "DefaultBranch"
      }
    ]
  }

  assert {
    condition     = length(var.branch_policies) == 3
    error_message = "All three valid `match_type` values should be accepted without validation errors."
  }

}
