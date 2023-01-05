@description('Azure region of the deployment')
param webAppName string = uniqueString(resourceGroup().id) // Generate unique String for web app name

param sku string = 'F1' // The SKU of App Service Plan
param linuxFxVersion string = 'node|14-lts' // The runtime stack of web app

@description('app service location')
param location string = resourceGroup().location // Location for all resources

@description('App service repo url')
param repositoryUrl string = 'https://github.com/MSFT-MCSEMEA-Demo/nodejs-docs-hello-world'

@description('App Service branch name')
param branch string = 'main'

@description('App Service isManual')
param ismanual bool = true

var appServicePlanName = toLower('AppServicePlan-${webAppName}')
var webSiteName = toLower('wapp-${webAppName}')

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  properties: {
    reserved: true
  }
  sku: {
    name: sku
  }
  kind: 'linux'
}

resource appService 'Microsoft.Web/sites@2020-06-01' = {
  name: webSiteName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: linuxFxVersion
    }
  }
}

resource srcControls 'Microsoft.Web/sites/sourcecontrols@2021-01-01' = {
  name: 'web'
  parent: appService
  properties: {
    repoUrl: repositoryUrl
    branch: branch
    isManualIntegration: ismanual
  }
}

output appserviceurl string = appService.properties.defaultHostName
output appsericeresourceid string = appService.id

