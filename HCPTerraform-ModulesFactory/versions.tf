terraform {

  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "~> 1.16"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.79"
    }
  }

  required_version = ">= 1.13.0"

}
