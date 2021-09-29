# Data From Existing Infrastructure

data "terraform_remote_state" "existing-hub" {
  backend = "azurerm"

  config = {
    storage_account_name = var.state_sa_name
    container_name       = var.container_name
    key                  = "hub-net"
    access_key = "JCl/6j8F390qcCUcLy+cG/QStbm+2fbuXu89MErlJOeTAeXqPS/Zi7nuCsLkHMVzN3cmJlU10xUKrQ/UkvTLjg=="
  }

}












