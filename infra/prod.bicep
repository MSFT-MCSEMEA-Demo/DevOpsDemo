targetScope = 'subscription'

param location string = deployment().location

@minLength(1)
@maxLength(16)
@description('Prefix for all deployed resources')
param name string

@description('SSH Public Key')
@secure()
param sshpublickey string

@description('AKS authorized ip range')
param authiprange string = ''

var resourcegroup = '${name}-rg' 
/* RESOURCE GROUP */
resource rg 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: resourcegroup
  location: location
}

var aksnodesresourcegroup = '${name}-aksnodes-rg' 
/* RESOURCE GROUP */
resource aksnoderg 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: aksnodesresourcegroup
  location: location
}

/* USER MANAGED IDENTITY */
module identity 'resources/managedid.bicep' = {
  name: '${rg.name}-identity'
  scope: aksnoderg
  params: {
    location: location
    managedIdentityName: toLower(name)
  }
}

var acrName = 'acr${uniqueString(rg.id)}' 
module acr 'resources/acr.bicep' = {
  name: '${rg.name}-acr'
  scope: rg
  params: {
    acrName: acrName
    location: rg.location
    manageidObjId: identity.outputs.managedIdentityPrincipalId 
  }
}

/*module loganalytic 'resources/loganalytic.bicep' = {
  name: '${rg.name}-loganalytic'
  scope: rg
  params: {
    workspaceName: '${toLower(name)}-loganalytic-ws'
    location: location
    newResourcePermissions: false
  }
}*/

var aksclustername = '${name}-aks'
var adminusername = '${name}admin'
module aks 'resources/aks.bicep' = {
  name: '${rg.name}-aks'
  scope: rg
  params: {
    clusterName: aksclustername
    adminusername: adminusername
    location: location
    clusterDNSPrefix: aksclustername       
    sshPubKey: sshpublickey
    iprange: authiprange
    managedIdentityName: identity.outputs.managedIdentityName  
    aksnoderg: aksnoderg.name
    //logAnalyticId: loganalytic.outputs.loganalyticworkspaceresourceid  
  }
}

output resourcegroupname string = rg.name
output acrloginserver string = acr.outputs.acrloginserver
output acrresourceid string = acr.outputs.acrresourceid
output acrresoucename string = acr.outputs.acrname
output aksclusterfqdn string = aks.outputs.aksclusterfqdn
output aksresourceid string = aks.outputs.aksresourceid
output aksresourcename string = aks.outputs.aksresourcename
output managedidentityprincipalid string = identity.outputs.managedIdentityPrincipalId
output managedidentityclientid string = identity.outputs.managedIdentityClientId
output managedidentityresourceid string = identity.outputs.managedIdentityResourceId
output managedidentityname string = identity.outputs.managedIdentityName
//output loganalyticresourceid string = loganalytic.outputs.loganalyticworkspaceresourceid
//output loganalyticresourcename string = loganalytic.outputs.loganalyticworkspacename
