# Create the Hub Network

The following will be created:
* Resource Group for Hub Neworking (hub-networking.tf)
* Hub Network (hub-networking.tf)
* Azure Firewall (firewall.tf)
* Azure Bastion Host (hub-networking.tf)
* Resource Group for Dev Jumpbox (dev-setup.tf)
* Virtual Machine (dev-setup.tf)

Navigate to "/Scenarios/AKS-Secure-Baseline-PrivateCluster/Terraform/04-Network-Hub" folder
```
cd ../04-Network-Hub
```

In the "provider.tf" file update the backend settings to reflect the storage account created for Terraform state management.  Do not change the "key" name, as it's referenced later in the deployment files.

In the "variables.tf" file, update the defaults to reflect the region, tags and prefix you'd like to use throughout the rest of the deployment.  There are a group of "sensitive" variables for the username and password of the jumpbox.  It is not recommended that these variables be commited to code in a public repo, you should instead create a separate terraform.tfvars file (not committed via gitignore) to pass those values in at deployment time. (A sample terraform.tfvars.sample file is included for reference. Enter your values and rename it terraform.tfvars)

Once the files are updated, deploy using Terraform Init, Plan and Apply.

```bash
terraform init
```

> Enter terraform init -reconfigure if you get an error saying there was a change in the backend configuration which may require migrating existing state

```bash
terraform plan
```

```bash
terraform apply
```

:arrow_forward: [Creation of Spoke Network & its respective Components](./05-network-lz.md)