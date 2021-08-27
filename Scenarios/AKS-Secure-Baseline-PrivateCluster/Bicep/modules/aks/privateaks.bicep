param basename string
param aadGroupdIds array
param logworkspaceid string
param privateDNSZoneId string
param subnetId string
param identity object
param principalId string

resource aksCluster 'Microsoft.ContainerService/managedClusters@2021-03-01' = {
  name: '${basename}aks'
  location: resourceGroup().location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: identity
  }
  properties: {
    kubernetesVersion: '1.19.9'
    nodeResourceGroup: '${basename}-aksInfraRG'
    dnsPrefix: '${basename}aks'
    agentPoolProfiles: [
      {
        name: 'default'
        count: 2
        vmSize: 'Standard_D4s_v3'
        mode: 'System'
        maxCount: 5
        minCount: 2
        maxPods: 50
        enableAutoScaling: true
        type: 'VirtualMachineScaleSets'
        vnetSubnetID: subnetId
      }
    ]
    networkProfile: {
      loadBalancerSku: 'standard'
      networkPlugin: 'azure'
      outboundType: 'userDefinedRouting'
      dockerBridgeCidr: '172.17.0.1/16'
      dnsServiceIP: '10.0.0.10'
      serviceCidr: '10.0.0.0/16'
      networkPolicy: 'azure'
    }
    apiServerAccessProfile: {
      enablePrivateCluster: true
      privateDNSZone: privateDNSZoneId
    }
    enableRBAC: true
    aadProfile: {
      adminGroupObjectIDs: aadGroupdIds
      enableAzureRBAC: true
      managed: true
      tenantID: subscription().tenantId
    }
    addonProfiles:{
      omsagent: {
        config: {
          logAnalyticsWorkspaceResourceID: logworkspaceid
        }
        enabled: true
      }
      azurepolicy: {
        enabled: true
      }
    }
  }
}

module aksPvtDNSContrib '../Identity/role.bicep' = {
  name: 'aksPvtDNSContrib'
  params: {
    principalId: principalId
    roleGuid: 'b12aa53e-6015-4669-85d0-8515ebb3ae7f' //Private DNS Zone Contributor
  }
}

module aksPvtNetworkContrib '../Identity/role.bicep' = {
  name: 'aksPvtNetworkContrib'
  params: {
    principalId: principalId
    roleGuid: '4d97b98b-1d4f-4787-a291-c67834d212e7' //Network Contributor
  }
}
