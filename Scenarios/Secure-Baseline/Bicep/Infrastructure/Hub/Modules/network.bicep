param hubNetwork object = {}

resource VNet_resource 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: hubNetwork.virtualNetwork.name
  location: resourceGroup().location
  dependsOn: [
    bastionNSG
  ]
  properties: {
    addressSpace: {
      addressPrefixes: [
        hubNetwork.virtualNetwork.addressPrefix
      ]
    }
    subnets: [for item in hubNetwork.virtualNetwork.subnets: {
      name: item.name
      properties: {
        addressPrefix: item.addressPrefix
        /*networkSecurityGroup: {
          id: resourceId('Microsoft.Network/networkSecurityGroups', item.NSGName)
        }*/
      }
    }]
    dhcpOptions: {
      dnsServers: [
        hubNetwork.virtualNetwork.dnsServers
      ]
    }
  }
}

resource bastionNSG 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: 'AzureBastionSubnet-nsg'
  location: resourceGroup().location
  properties: {
    securityRules: [
      {
        name: 'AllowWebExperienceInBound'
        properties: {
          access: 'Allow'
          description: 'Allow our users in. Update this to be as restrictive as possible.'
          destinationAddressPrefix: '*'
          destinationPortRange: '443'
          direction: 'Inbound'
          priority: 100
          protocol: 'Tcp'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowControlPlaneInBound'
        properties: {
          access: 'Allow'
          description: 'Service Requirement. Allow control plane access. Regional Tag not yet supported.'
          destinationAddressPrefix: '*'
          destinationPortRange: '443'
          direction: 'Inbound'
          priority: 110
          protocol: 'Tcp'
          sourceAddressPrefix: 'GatewayManager'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowHealthProbesInBound'
        properties: {
          access: 'Allow'
          description: 'Service Requirement. Allow Health Probes.'
          destinationAddressPrefix: '*'
          destinationPortRange: '443'
          direction: 'Inbound'
          priority: 120
          protocol: 'Tcp'
          sourceAddressPrefix: 'AzureLoadBalancer'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowBastionHostToHostInBound'
        properties: {
          access: 'Allow'
          description: 'Service Requirement. Allow Required Host to Host Communication.'
          destinationAddressPrefix: '*'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          direction: 'Inbound'
          priority: 130
          protocol: 'Tcp'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'DenyAllInBound'
        properties: {
          access: 'Deny'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
          direction: 'Inbound'
          priority: 1000
          protocol: '*'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowSshToVnetOutBound'
        properties: {
          access: 'Allow'
          description: 'Allow SSH out to the VNet'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '22'
          direction: 'Outbound'
          priority: 100
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowRdpToVnetOutBound'
        properties: {
          access: 'Allow'
          description: 'Allow RDP out to the VNet'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '3389'
          direction: 'Outbound'
          priority: 110
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowControlPlaneOutBound'
        properties: {
          access: 'Allow'
          description: 'Required for control plane outbound. Regional prefix not yet supported'
          destinationAddressPrefix: 'AzureCloud'
          destinationPortRange: '443'
          direction: 'Outbound'
          priority: 120
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowBastionHostToHostOutBound'
        properties: {
          access: 'Allow'
          description: 'Service Requirement. Allow Required Host to Host Communication.'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          direction: 'Outbound'
          priority: 130
          protocol: 'Tcp'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowBastionCertificateValidationOutBound'
        properties: {
          access: 'Allow'
          description: 'Service Requirement. Allow Required Session and Certificate Validation.'
          destinationAddressPrefix: 'Internet'
          destinationPortRange: '80'
          direction: 'Outbound'
          priority: 140
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
        }
      }
      {
        name: 'DenyAllOutBound'
        properties: {
          access: 'Deny'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
          direction: 'Outbound'
          priority: 1000
          protocol: '*'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
        }
      }
    ]
  }
}

resource publicIP 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: '${hubNetwork.azureFirewall.name}-pip'
  location: hubNetwork.azureFirewall.location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

resource hubfirewall 'Microsoft.Network/azureFirewalls@2020-06-01' = {
  name: hubNetwork.azureFirewall.name
  location: hubNetwork.azureFirewall.location
  dependsOn: [
    VNet_resource
  ]
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf1'
        properties: {
          subnet: {
            id: resourceId('${hubNetwork.virtualNetwork.rg}', 'Microsoft.Network/virtualNetworks/subnets', hubNetwork.virtualNetwork.name, 'AzureFirewallSubnet')
          }
          publicIPAddress: {
            id: publicIP.id
          }
        }
      }
    ]
    applicationRuleCollections: [
      {
        name: 'appRc1'
        properties: {
          priority: 101
          action: {
            type: 'Allow'
          }
          rules: [
            {
              name: 'appRule1'
              protocols: [
                {
                  port: 80
                  protocolType: 'Http'
                }
              ]
              targetFqdns: [
                'www.microsoft.com'
              ]
              sourceAddresses: [
                '10.0.0.0/24'
              ]
            }
          ]
        }
      }
    ]
    networkRuleCollections: [
      {
        name: 'netRc1'
        properties: {
          priority: 200
          action: {
            type: 'Allow'
          }
          rules: [
            {
              name: 'netRule1'
              protocols: [
                'TCP'
              ]
              sourceAddresses: [
                '10.0.0.0/24'
              ]
              destinationAddresses: [
                '*'
              ]
              destinationPorts: [
                '8000-8999'
              ]
            }
          ]
        }
      }
    ]
  }
}

