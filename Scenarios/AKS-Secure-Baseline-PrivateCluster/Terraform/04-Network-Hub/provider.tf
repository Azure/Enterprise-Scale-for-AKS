terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.77.0"
    }

  }

  backend "azurerm" {
    resource_group_name  = "tfstate" # Update this value
    storage_account_name = "tfstate-sa" # Update this value
    container_name       = "akscs" # Update this value
    key                  = "hub-net"
  }

}

provider "azurerm" {
  features {}
}