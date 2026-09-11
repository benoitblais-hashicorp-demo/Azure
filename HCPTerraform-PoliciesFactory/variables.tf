variable "organization_name" {
  description = "(Required) Name of the organization."
  type        = string
  nullable    = false
}

# Uncomment the following variables to enable the VCS-backed AWS CIS policy set.
# Both variables must be set together with the `cis_aws` resource in main.tf.

# variable "aws_cis_git_repository_identifier" {
#   description = "The VCS repository identifier for the CIS Policy Set. `oauth_client_name` must also be set."
#   type        = string
#   default     = "benoitblais-azuredevops/HCPTerraform-CIS-Policy-Set-for-AWS-Terraform"
# }

# variable "oauth_client_name" {
#   description = "(Optional) Name of the OAuth client."
#   type        = string
#   nullable    = false
#   default     = "Azure DevOps Services"
# }

variable "policies_folder" {
  description = "The name of the folder where policies are located."
  type        = string
  default     = "./policies"
}
