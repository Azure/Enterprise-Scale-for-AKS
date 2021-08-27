targetScope = 'subscription'

param rgs array

module resourceGrp '../modules/resource-group/rg.bicep' = [for rg in rgs: {
  name: rg.name
  params: {
    location: rg.location
    tags: rg.tags
    rgName: rg.name
  }
}]
