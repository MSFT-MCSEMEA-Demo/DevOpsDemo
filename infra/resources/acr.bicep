@minLength(5)
@maxLength(50)
@description('Provide a globally unique name of your Azure Container Registry')
param acrName string = 'acr${uniqueString(resourceGroup().id)}'

@description('Provide a location for the registry.')
param location string = resourceGroup().location

@description('Provide a tier of your Azure Container Registry.')
@allowed([
  'Basic'
  'Standard'
])
param acrSku string = 'Basic'

resource acrResource 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: true
    anonymousPullEnabled: false
  }
}

output acrname string = acrResource.name
output acrresourceid string = acrResource.id
output acrloginserver string = acrResource.properties.loginServer
