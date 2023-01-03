targetScope = 'subscription'

param location string = deployment().location

@minLength(1)
@maxLength(16)
@description('Prefix for all deployed resources')
param name string

@description('SSH Public Key')
@secure()
param sshpublickey string

//@description('AKS authorized ip range')
//param authiprange string = '46.117.129.35'

var resourcegroup = '${name}-rg' 
/* RESOURCE GROUP */
resource rg 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: resourcegroup
  location: location
}

var acrName = 'acr${uniqueString(rg.id)}' 
module acr 'resources/acr.bicep' = {
  name: acrName
  scope: rg
  params: {
    acrName: acrName
    location: rg.location
  }
}

var aksclustername = '${name}-aks'
var adminusername = '${name}admin'
module aks 'resources/aks.bicep' = {
  name: aksclustername
  scope: rg
  params: {
    clusterName: aksclustername
    adminusername: adminusername
    location: location
    clusterDNSPrefix: aksclustername       
    sshPubKey: sshpublickey
    //iprange: authiprange
  }
}

output resourcegroupname string = rg.name
output acrloginserver string = acr.outputs.acrloginserver
output acrresourceid string = acr.outputs.acrresourceid
output acrresoucename string = acr.outputs.acrname
output aksclusterfqdn string = aks.outputs.aksclusterfqdn
output aksresourceid string = aks.outputs.aksresourceid
output aksresourcename string = aks.outputs.aksresourcename

