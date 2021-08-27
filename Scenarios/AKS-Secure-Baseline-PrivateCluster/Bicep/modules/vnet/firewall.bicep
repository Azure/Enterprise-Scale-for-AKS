param fwname string
param applicationRuleCollections array
param networkRuleCollections array
param natRuleCollections array
param publicIp object
param vnetName string
param location string = resourceGroup().location

module publicipfirewall '../vnet/publicip.bicep' = {
  name: publicIp.publicipName
  params: {
    publicipName: publicIp.publicipName
    publicipproperties: publicIp.publicipproperties
    publicipsku: publicIp.publicipsku
  }
}

resource subnetfirewall 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' existing = {
  name: '${vnetName}/AzureFirewallSubnet'
}

resource firewall 'Microsoft.Network/azureFirewalls@2020-11-01' = {
  name: fwname
  location: location
  properties: {
    ipConfigurations: [
        {
          name: 'fwPublicIP'
          properties: {
            subnet: {
              id: subnetfirewall.id
            }
            publicIPAddress: {
              id: publicipfirewall.outputs.publicipId
            }
          }
        }
    ]
    applicationRuleCollections: applicationRuleCollections
    networkRuleCollections: networkRuleCollections    
    natRuleCollections: natRuleCollections
  }
}
output fwPrivateIP string = firewall.properties.ipConfigurations[0].properties.privateIPAddress
output fwName string = firewall.name
