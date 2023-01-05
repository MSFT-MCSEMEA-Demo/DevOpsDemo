
@description('storage name')
param name string

@description('Azure region for resources')
param location string = resourceGroup().location


resource storage 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: name
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: true
    supportsHttpsTrafficOnly: true

  }
}

output storageaccountname string = storage.name
output storageresourceid string = storage.id
output storagebloburi string = storage.properties.primaryEndpoints.blob
