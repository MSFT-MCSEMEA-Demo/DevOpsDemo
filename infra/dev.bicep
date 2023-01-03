targetScope = 'subscription'

param location string = deployment().location

@minLength(1)
@maxLength(16)
@description('Prefix for all deployed resources')
param name string

@description('SSH Public Key')
@secure()
param sshpublickey string

var resourcegroup = '${name}-rg' 
/* RESOURCE GROUP res */
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

module loganalytic 'resources/loganalytic.bicep' = {
  name: '${rg.name}-loganalytic'
  scope: rg
  params: {
    workspaceName: '${toLower(name)}-loganalytic-ws'
    location: location
    newResourcePermissions: false
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
    logAnalyticId: loganalytic.outputs.loganalyticworkspaceresourceid
  }
}

output resourcegroupname string = rg.name
output acrloginserver string = acr.outputs.acrloginserver
output acrresourceid string = acr.outputs.acrresourceid
output acrresoucename string = acr.outputs.acrname
output aksclusterfqdn string = aks.outputs.aksclusterfqdn
output aksresourceid string = aks.outputs.aksresourceid
output aksresourcename string = aks.outputs.aksresourcename
output loganalyticresourceid string = loganalytic.outputs.loganalyticworkspaceresourceid
output loganalyticresourcename string = loganalytic.outputs.loganalyticworkspacename

