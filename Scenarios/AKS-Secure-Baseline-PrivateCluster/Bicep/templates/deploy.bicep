param vnets array = []
param bastion object = {}
param firewall object = {}
param virtualMachines array = []

module vnetResource '../modules/vnet/virtualNetwork.bicep' = [for vnet in vnets: {
  name: vnet.name
  params: {
    location: vnet.location
    tags: vnet.tags
    vnetName: vnet.name
    subnets: vnet.subnets
    vnetAddressSpace: vnet.vnetaddressSpace
  }
}]

module bastionResource '../modules/VM/bastion.bicep' = {
  name: bastion.name
  params: {
    bastionVnetName: bastion.bastionVnetName
    publicip: bastion.publicip
  }
}

module virtualMachineResource '../modules/VM/virtualmachine.bicep' = [for vm in virtualMachines: {
  name: vm.vmName
  params: {
    vmName: vm.vmName
    vmSize: vm.vmSize
    userName: vm.userName
    publicKey: vm.publickey
    vnetName: vm.vnetName
    vmSubnetName: vm.vmSubnetName
  }
}]

module firewalResource '../modules/vnet/firewall.bicep' = {
  name: firewall.fwname
  params: {
    applicationRuleCollections: firewall.applicationRuleCollections
    fwname: firewall.fwname
    natRuleCollections: firewall.natRuleCollections
    networkRuleCollections: firewall.networkRuleCollections
    publicIp: firewall.publicIp
    vnetName: firewall.vnetName
  }
}
