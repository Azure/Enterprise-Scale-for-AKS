param vnetAddressSpace object
param tags object
param vnetName string
param subnets array
param location string

resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: vnetAddressSpace
    subnets: subnets
  }
}

output vnetId string = vnet.id
output vnetName string = vnet.name
output vnetSubnets array = vnet.properties.subnets
