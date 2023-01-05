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

/* USER MANAGED IDENTITY */
module identity 'resources/managedid.bicep' = {
  name: '${rg.name}-identity'
  scope: rg
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
    //logAnalyticId: loganalytic.outputs.loganalyticworkspaceresourceid  
  }
}


var storagename = '${name}storage'
module storage 'resources/storage.bicep' = {
  name: '${rg.name}-storage'
  scope: rg
  params: {
    name: storagename
    location: location    
  }
}

module website 'resources/appservice.bicep' = {
  name: '${rg.name}-website'
  scope: rg
  params: {
    //ismanual: true
    //branch: 'main'
    sku: 'B1'
    location: location 
  }
}

var mysqlname = '${name}mysql'
module mysql 'resources/mysql.bicep' = {
  name: '${rg.name}-mysql'
  scope: rg
  params: {
    serverName: mysqlname
    location: location
    administratorLogin: 'prodadminuser'
    administratorLoginPassword: 'Demopass123'
    isprod: true
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
output storageaccountname string = storage.outputs.storageaccountname
output storageresourceid string = storage.outputs.storageresourceid
output storagebloburi string = storage.outputs.storagebloburi
output appserviceurl string = website.outputs.appserviceurl
output appsericeresourceid string = website.outputs.appsericeresourceid
output mysqlresourceid string = mysql.outputs.mysqlresourceid
//output loganalyticresourceid string = loganalytic.outputs.loganalyticworkspaceresourceid
//output loganalyticresourcename string = loganalytic.outputs.loganalyticworkspacename
