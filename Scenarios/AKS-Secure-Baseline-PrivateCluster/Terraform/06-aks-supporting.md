# Create resources that support AKS

The following will be created:
* Azure Container Registry (supporting-infra.tf)
* Azure Key Vault (supporting-infra.tf)
* Private Link Endpoints for ACR and Key Vault
* Mongo DB Secret (mongo-secret.tf) -- OPTIONAL

Navigate to "/Scenarios/AKS-Secure-Baseline-PrivateCluster/Terraform/06-AKS-supporting" folder
```
cd ../06-AKS-supporting
```

In the "provider.tf" file, update the backend settings to reflect the storage account created for Terraform state management.  Do not change the "key" name, as it's referenced later in the deployment files.

In the "variables.tf" file, update the defaults to reflect prefix you'd like to use.
This deployment will need to reference data objects from the Hub deployment and will need access to the pre-existing state file, update the variables as needed.  Once again, this deployment will also need to use a storage access key (from Azure) to read the storage account data.  This is a sensitive variable and should not be committed to the code repo.

## A Note about MongoDB

Sample code is provided to add a secret for the MongoDB connection string to the Azure Key Vault, which would be referenced by the application workload later. However, this is a "data plane" operation and networking restrictions on the Key Vault deployment will not allow this code to succeed if from a client machine outside of the hub or spoke virtual network. If you are running this from a machine within the hub or spoke virtual network, for example by using the jumpbox vm created earlier, feel free to rename the mongo-secret.tf.sample file to mongo-secret.tf to create the mongodb secret and grant access to the current user.

Otherwise skip this part for now, we will create the secret manually using Azure CLI later.

### Add the Access key variable to terraform.tfvars

1. Open the *terraform.tfvars.sample* file and add the access key as the value of the access_key variable.

2. Modify the connection string for mongodb if you would like to add the secret to Azure Key Vault using terraform per the instructions above.
3. Rename the file to *terraform.tfvars*

Once the files are updated, deploy using Terraform Init, Plan and Apply.

```
terraform init
```

```
terraform plan
```

```
terraform apply
```


:arrow_forward: [Creation of AKS & enabling Addons](./07-aks-cluster.md)