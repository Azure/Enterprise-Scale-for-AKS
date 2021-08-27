param vnetName string
param peeringName string
param vnetId string

resource peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-11-01' = {
  name: '${vnetName}/${peeringName}'
  properties: {
    allowVirtualNetworkAccess: true
      allowForwardedTraffic: true
      remoteVirtualNetwork: {
        id: vnetId
      }
  }
}
