# Create resources for the AKS Cluster

The following will be created:

* AKS Cluster with KeyVault (preview), AGIC and monitoring addons
* Log Analytics Workspace
* ACR Access to the AKS Cluster
* Updates to KeyVault access policy with AKS keyvault addon

Navigate to "/Scenarios/AKS-Secure-Baseline-PrivateCluster/Bicep/06-AKS-cluster" folder

```bash
cd ../06-AKS-cluster
```

To create an AKS cluster that can use the Secrets Store CSI Driver, you must enable the AKS-AzureKeyVaultSecretsProvider feature flag on your subscription. Register the AKS-AzureKeyVaultSecretsProvider feature flag by using the az feature register command, as shown below

```bash
az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService/AKS-AzureKeyVaultSecretsProvider')].{Name:name,State:properties.state}"
```

if not enter the command below to enable it

```bash
az feature register --namespace "Microsoft.ContainerService" --name "AKS-AzureKeyVaultSecretsProvider"
```

It takes a few minutes for the status to show *Registered*. Verify the registration status by using the [az feature list](https://docs.microsoft.com/en-us/cli/azure/feature#az_feature_list) command:

```bash
az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService/AKS-AzureKeyVaultSecretsProvider')].{Name:name,State:properties.state}"
```

When ready, refresh the registration of the *Microsoft.ContainerService* resource provider by using the [az provider register](https://docs.microsoft.com/en-us/cli/azure/provider#az_provider_register) command:

```bash
az provider register --namespace Microsoft.ContainerService
```

There are a few additional Azure Providers and features that needs to be registered as well. Follow the same steps above for the following providers and features:

- Microsoft.ContainerService
- EnablePodIdentityPreview
- AKS-AzureKeyVaultSecretsProvider
- Microsoft.OperationsManagement
- Microsoft.OperationalInsights

Here is a list with all required providers or features to be registered:

```bash
az provider register --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.OperationsManagement
az provider register --namespace Microsoft.OperationalInsights
az feature register --name EnablePodIdentityPreview --namespace Microsoft.ContainerService
az feature register --namespace "Microsoft.ContainerService" --name "AKS-AzureKeyVaultSecretsProvider"
```

Review "parameters-main.json" file and update the values as required. Please make sure to update the AAD Group IDs with ones created in Step 02 and kubernetesVersion in the parameters file. Once the files are updated, deploy using az cli or Az PowerShell.

There are two groups you need to change in parameters-main.json: 
    - Admin group which will grant the role "Azure Kubernetes Service Cluster Admin Role". The parameter name is: aksadminaccessprincipalId.
    - Dev/User group which will grant "Azure Kubernetes Service Cluster User Role". The parameter name is: aksadminaccessprincipalId.

You can choose which AKS network plugin you want to deploy the cluster: azure or kubenet.
For azure network plugin each pod in the cluster will have an IP from the AKS Subnet CIDR. It allows Application Gateway and any other external service to reach the pod using this IP.

For kubenet all the PODs get an IP address from POD-CIDR within the cluster. To route traffic to these pods the TCP/UDP flow must go to the node where the pod resides. By default AKS will maintain the UDR associated with the subnet where it belongs to always updated with the CIDR /24 of the respective POD/Node ip.

Application Gateway Ingress Controller (AGIC) is deployed in a dedicated subnet without any UDR associated. It means Application Gateway doesn't know how to route the traffic of a POD backeend pool in a AKS using kubenete. It's possible to create a manual route table to address this problem momentously but once a node scale operation happen the route should be updated again. It's possible to use an Azure external solution to watch to those scaling operations and auto-update the routes using Azure Automation, Azure Functions or Logic Apps. Azure Application Gateway v2 (only supported version with AGIC) currently doesn't support a route 0.0.0.0/0 associated to a route table, because if this limitation you cannot associate the default AKS UDR to Application Gateway subnet since AKS with egress control requires a 0.0.0.0/0 route.

Reference:
[How to setup networking between Application Gateway and AKS](https://azure.github.io/application-gateway-kubernetes-ingress/how-tos/networking/)
[Use kubenet networking with your own IP address ranges in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/configure-kubenet)
[Application Gateway infrastructure configuration](https://docs.microsoft.com/en-us/azure/application-gateway/configuration-infrastructure#supported-user-defined-routes)
[Using AKS kubenet egrees control with AGIC](https://github.com/Welasco/AKS-AGIC-UDR-AutoUpdate)

The Kubernetes community releases minor versions roughly every three months. AKS has it own supportability policy based in the community releases. Before proceed with the deployment check the latest version reviewing the [supportability doc](https://docs.microsoft.com/en-us/azure/aks/supported-kubernetes-versions). You can also check the latest version using the following command:

```azurecli
az aks get-versions -l <region>
```
# [CLI](#tab/CLI)

```azurecli
acrName=$(az deployment sub show -n "ESLZ-AKS-Supporting" --query properties.outputs.acrName.value -o tsv)
keyVaultName=$(az deployment sub show -n "ESLZ-AKS-Supporting" --query properties.outputs.keyvaultName.value -o tsv)

# Deploy Using Azure Network CNI plugin
az deployment sub create -n "ESLZ-AKS-CLUSTER" -l "CentralUS" -f 06-AKS-cluster/main.bicep -p 06-AKS-cluster/parameters-main.json -p acrName=$acrName -p keyvaultName=$keyVaultName -p kubernetesVersion=1.22.6 -p networkPlugin=azure

# Deploy using Azure Network Kunet plugin
az deployment sub create -n "ESLZ-AKS-CLUSTER" -l "CentralUS" -f 06-AKS-cluster/main.bicep -p 06-AKS-cluster/parameters-main.json -p acrName=$acrName -p keyvaultName=$keyVaultName -p kubernetesVersion=1.22.6 -p networkPlugin=kubenet
```

# [PowerShell](#tab/PowerShell)

```azurepowershell
New-AzSubscriptionDeployment -TemplateFile .\06-AKS-cluster\main.bicep -TemplateParameterFile .\06-AKS-cluster\parameters-main.json -Location "CentralUS" -Name ESLZ-AKS-CLUSTER
```

:arrow_forward: [Deploy a Basic Workload](./07-workload.md)