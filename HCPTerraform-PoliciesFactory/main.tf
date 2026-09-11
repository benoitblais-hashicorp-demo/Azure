# The following code block is used to create Terraform Cloud Policies.

locals {
  # This local is used to get a list of all folder inside the policies folder.
  files = fileset(var.policies_folder, "*/*.sentinel")
}

module "description" {
  for_each = local.files
  source   = "./modules/get_description"
  path     = "${var.policies_folder}/${each.key}"
}

resource "tfe_policy" "this" {
  for_each     = local.files
  name         = element(split(".", element(split("/", each.key), 1)), 2)
  description  = module.description[each.value].description
  organization = var.organization_name
  kind         = "sentinel"
  policy       = file("${var.policies_folder}/${each.key}")
  enforce_mode = "hard-mandatory" # advisory, hard-mandatory and soft-mandatory
}

# The following code block is used to create Terraform Cloud Policy Sets.

resource "tfe_policy_set" "global" {
  name         = "Global-Policy-Set"
  description  = "This policy-set is assigned at the organization level."
  organization = var.organization_name
  global       = true
  kind         = "sentinel"
  policy_ids   = [for value in tfe_policy.this : value.id]
}

# The following block is used to get information about an OAuth client.
# Uncomment this block along with the `cis_aws` policy set below and the
# `aws_cis_git_repository_identifier` and `oauth_client_name` variables
# to enable a VCS-backed AWS CIS policy set.

# data "tfe_oauth_client" "client" {
#   count        = var.oauth_client_name != null ? 1 : 0
#   organization = var.organization_name
#   name         = var.oauth_client_name
# }

# The following block is used to create a Policy Set from a VCS repository for AWS CIS.

# resource "tfe_policy_set" "cis_aws" {
#   count        = var.aws_cis_git_repository_identifier != null ? 1 : 0
#   name         = "AWS-CIS-Policy-Set"
#   description  = "This policy-set is assigned at the organization level."
#   organization = var.organization_name
#   global       = true
#   kind         = "sentinel"
#   vcs_repo {
#     identifier         = var.aws_cis_git_repository_identifier
#     branch             = "main"
#     ingress_submodules = false
#     oauth_token_id     = data.tfe_oauth_client.client[0].oauth_token_id
#   }
#   lifecycle {
#     precondition {
#       condition     = var.oauth_client_name != null ? true : false
#       error_message = "`oauth_client_name` must be set when `aws_cis_git_repository_identifier` is set."
#     }
#   }
# }