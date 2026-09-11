# The following locals block constructs derived values used throughout this configuration.

locals {
  # display_identifier: unencoded form returned by the HCP Terraform API on read-back.
  # Format: <org>/<project with spaces>/_git/<repo>
  # Must include /_git/ to match what the API returns, otherwise every plan shows a diff.
  vcs_display_identifier = "${var.azuredevops_organization}/${var.azuredevops_project_name}/_git/${module.repository.repository.name}"

  # identifier: URL-encoded form required by the HCP Terraform API when creating/updating
  # the registry module VCS connection.
  # Format: <org>/<project%20encoded>/_git/<repo>
  vcs_identifier = "${var.azuredevops_organization}/${replace(var.azuredevops_project_name, " ", "%20")}/_git/${module.repository.repository.name}"

  # repo_name: canonical ADO repository name, always lower-cased per the module convention.
  repo_name = lower("terraform-${var.module_provider}-${var.module_name}")

  # tag_pipeline_name: the full display name the tag-pipeline will be registered under in ADO.
  # This must be rendered into release-pipeline.yml so its resources.pipelines[].source
  # matches the registered name exactly.
  tag_pipeline_name = "${local.repo_name} — tag-pipeline"

  # initial_files: when the caller does not supply an explicit list, read every scaffold file
  # from the template/ directory bundled with this module so that pipeline YAML content is
  # loaded via file() rather than being inlined as an escaped HCL string.
  # release-pipeline.yml contains the placeholder __TAG_PIPELINE_NAME__ which is replaced
  # here with the actual registered pipeline name so the resources.pipelines[].source value
  # matches exactly — no .tftpl extension or templatefile() needed.
  initial_files = var.initial_files != null ? var.initial_files : [
    { path = ".gitignore",                        content = file("${path.module}/template/.gitignore") },
    { path = "README.md",                         content = file("${path.module}/template/README.md") },
    { path = "main.tf",                           content = file("${path.module}/template/main.tf") },
    { path = "variables.tf",                      content = file("${path.module}/template/variables.tf") },
    { path = "outputs.tf",                        content = file("${path.module}/template/outputs.tf") },
    { path = "versions.tf",                       content = file("${path.module}/template/versions.tf") },
    { path = "tests/main.tf.tftest.hcl",          content = file("${path.module}/template/tests/main.tf.tftest.hcl") },
    { path = "tests/variables.tf.tftest.hcl",     content = file("${path.module}/template/tests/variables.tf.tftest.hcl") },
    { path = "pipelines/merge-pipeline.yml",      content = file("${path.module}/template/pipelines/merge-pipeline.yml") },
    { path = "pipelines/tag-pipeline.yml",        content = file("${path.module}/template/pipelines/tag-pipeline.yml") },
    { path = "pipelines/release-pipeline.yml",    content = replace(file("${path.module}/template/pipelines/release-pipeline.yml"), "__TAG_PIPELINE_NAME__", local.tag_pipeline_name) },
    { path = "docs/pull_request_template.md",     content = file("${path.module}/template/docs/pull_request_template.md") },
  ]
}

# The following data source looks up the Azure DevOps project by name to obtain its UUID,
# which is required by all azuredevops_* resources.

data "azuredevops_project" "this" {
  name = var.azuredevops_project_name
}

# The following block is used to get information about the OAuth client.
# The oauth_token_id (ot-...) it exposes is required by tfe_registry_module.

data "tfe_oauth_client" "client" {
  organization = var.organization_name
  name         = var.oauth_client_name
}

# The following module block is used to create and manage the Azure DevOps repository.

module "repository" {
  source                = "./modules/azuredevops_repository"
  name                  = local.repo_name
  project_id            = data.azuredevops_project.this.id
  default_branch        = var.default_branch
  disabled              = var.disabled
  initialization        = var.template_source_url != null ? {
    init_type  = "Import"
    source_url = var.template_source_url
  } : var.initialization
  initial_files         = local.initial_files
  pipeline_name_prefix  = local.repo_name
  branch_policies       = var.branch_policies
}

# The following code block is used to create module resources in the private registry.

resource "tfe_registry_module" "this" {
  organization    = var.organization_name
  initial_version = "0.0.0"
  test_config {
    tests_enabled = true
  }
  vcs_repo {
    display_identifier = local.vcs_display_identifier
    identifier         = local.vcs_identifier
    oauth_token_id     = data.tfe_oauth_client.client.oauth_token_id
    branch             = var.default_branch
  }

  # display_identifier is ignored after initial creation because the HCP Terraform API
  # returns a normalised form (without /_git/) on read-back regardless of what was written,
  # causing a perpetual diff on every plan. The identifier and branch are what matter for
  # the VCS connection — display_identifier is cosmetic only.
  lifecycle {
    ignore_changes = [vcs_repo[0].display_identifier]
  }
}

resource "tfe_no_code_module" "this" {
  count           = var.no_code_module ? 1 : 0
  organization    = var.organization_name
  registry_module = tfe_registry_module.this.id
}

# The following resource blocks create test variables used when running module tests in HCP Terraform.
# These mirror the variables defined in the calling workspace's variable set so that
# terraform test runs inside HCP Terraform have the same credentials available.

resource "tfe_test_variable" "azdo_org_service_url" {
  key             = "AZDO_ORG_SERVICE_URL"
  value           = data.tfe_oauth_client.client.http_url
  category        = "env"
  module_name     = tfe_registry_module.this.name
  module_provider = tfe_registry_module.this.module_provider
  organization    = var.organization_name
  sensitive       = false
}

resource "tfe_test_variable" "azuredevops_organization" {
  key             = "TF_VAR_azuredevops_organization"
  value           = var.azuredevops_organization
  category        = "env"
  module_name     = tfe_registry_module.this.name
  module_provider = tfe_registry_module.this.module_provider
  organization    = var.organization_name
  sensitive       = false
}

resource "tfe_test_variable" "azuredevops_project_name" {
  key             = "TF_VAR_azuredevops_project_name"
  value           = var.azuredevops_project_name
  category        = "env"
  module_name     = tfe_registry_module.this.name
  module_provider = tfe_registry_module.this.module_provider
  organization    = var.organization_name
  sensitive       = false
}

resource "tfe_test_variable" "oauth_client_name" {
  key             = "TF_VAR_oauth_client_name"
  value           = var.oauth_client_name
  category        = "env"
  module_name     = tfe_registry_module.this.name
  module_provider = tfe_registry_module.this.module_provider
  organization    = var.organization_name
  sensitive       = false
}

resource "tfe_test_variable" "organization_name" {
  key             = "TF_VAR_organization_name"
  value           = var.organization_name
  category        = "env"
  module_name     = tfe_registry_module.this.name
  module_provider = tfe_registry_module.this.module_provider
  organization    = var.organization_name
  sensitive       = false
}

