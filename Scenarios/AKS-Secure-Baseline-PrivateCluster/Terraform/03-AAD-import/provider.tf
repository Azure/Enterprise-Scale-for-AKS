# Update the variables in the BACKEND block to refrence the 
# storage account created out of band for TF statemanagement.

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.79.0"
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
  client_id        = var.client_id
  client_secret    = var.client_secret
  subscription_id  = var.subscription_id
  tenant_tenant_id = var.tenant_id
}

provider "azuread" {
}