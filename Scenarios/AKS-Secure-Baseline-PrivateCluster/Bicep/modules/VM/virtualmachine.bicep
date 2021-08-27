param vnetName string
param vmSubnetName string
param userName string
param publicKey string
param vmName string
param vmSize string

resource subnetVM 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' existing = {
  name: '${vnetName}/${vmSubnetName}'
}

module jbnic '../vnet/nic.bicep' = {
  name: 'jbnic'
  params: {
    subnetId: subnetVM.id
  }
}

resource jumpbox 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: vmName
  location: resourceGroup().location
  properties: {
    osProfile: {
      computerName: vmName
      adminUsername: userName
      linuxConfiguration: {
        ssh: {
          publicKeys: [
            {
              path: '/home/${userName}/.ssh/authorized_keys'
              keyData: publicKey
            }
          ]
        }
        disablePasswordAuthentication: true
      }
    }
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: jbnic.outputs.nicId
        }
      ]
    }
  }
}
