# Update the variables in the BACKEND block to refrence the 
# storage account created out of band for TF statemanagement.

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.79.1"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.2.0"
    }

  }

  backend "azurerm" {
    # resource_group_name  = ""   # Partial configuration, provided during "terraform init"
    # storage_account_name = ""   # Partial configuration, provided during "terraform init"
    # container_name       = ""   # Partial configuration, provided during "terraform init"
    key                  = "aad"
  }

}

provider "azurerm" {
  features {}
}

provider "azuread" {
}