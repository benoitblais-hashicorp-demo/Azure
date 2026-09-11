terraform {
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "~> 1.16"
    }
  }

  required_version = ">= 1.13.0"
}
