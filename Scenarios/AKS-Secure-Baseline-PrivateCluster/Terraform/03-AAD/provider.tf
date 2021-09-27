# Update the variables in the BACKEND block to refrence the
# storage account created out of band for TF statemanagement.

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.77.0" #Update to more current provider
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.3.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "tfstate" # Update this value
    storage_account_name = "tfstate-sa" # Update this value
    container_name       = "akscs" # Update this value
    key                  = "aad"
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {
}