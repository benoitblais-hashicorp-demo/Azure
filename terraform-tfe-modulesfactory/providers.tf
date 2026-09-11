# The azuredevops provider reads credentials from environment variables:
#   AZDO_ORG_SERVICE_URL          → https://dev.azure.com/<organization>
#   AZDO_PERSONAL_ACCESS_TOKEN    → Personal Access Token
# The tfe provider reads its token from:
#   TFE_TOKEN                     → HCP Terraform API token

provider "azuredevops" {}

provider "tfe" {}
