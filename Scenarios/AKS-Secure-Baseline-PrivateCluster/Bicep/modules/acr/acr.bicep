param acrName string

resource acr 'Microsoft.ContainerRegistry/registries@2020-11-01-preview' = {
  name: acrName
  location: resourceGroup().location
  sku: {
    name: 'Premium'
  }
  properties: {
    adminUserEnabled: true
  }
}

output acrid string = acr.id
