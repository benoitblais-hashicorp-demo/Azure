terraform {

  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.79"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.14"
    }
  }

  required_version = ">= 1.13.0"

}
