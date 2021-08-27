param publicip object
param bastionVnetName string

module publicipbastion '../vnet/publicip.bicep' = {
  name: publicip.publicipName
  params: {
    publicipName: publicip.publicipName
    publicipproperties: publicip.publicipproperties
    publicipsku: publicip.publicipsku
  }
}

resource subnetbastion 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' existing = {
  name: '${bastionVnetName}/AzureBastionSubnet'
}

resource bastion 'Microsoft.Network/bastionHosts@2021-02-01' = {
  name: 'bastion'
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconf'
        properties: {
          publicIPAddress: {
            id: publicipbastion.outputs.publicipId
          }
          subnet: {
            id: subnetbastion.id
          }
        }
      }
    ]
  }
}
