@description('Azure region of the deployment')
param location string = resourceGroup().location

@description('AKS resource name')
param clusterName string

@description('AKS dns prefix')
param clusterDNSPrefix string

@description('Admin user name for AKS node')
param adminusername string

@description('AKS node ssh public key')
@secure()
param sshPubKey string

@description('AKS authorized ip range')
param iprange string = ''

@description('LogAnalytic workspace id')
param logAnalyticId string = ''

@description('Managed identity Principal id')
param managedIdentityName string

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: managedIdentityName
}

resource akscluster 'Microsoft.ContainerService/managedClusters@2022-05-02-preview' = {
  name: clusterName
  location: location
  identity: {
    type:'SystemAssigned' 
  }
  properties: {
    dnsPrefix: clusterDNSPrefix
    enableRBAC: true
    apiServerAccessProfile: !empty(iprange) ? {
      authorizedIPRanges: [iprange]
    } : null
    agentPoolProfiles: [
      {
        name: 'agentpool'
        osDiskSizeGB: 30
        count: 1
        vmSize: 'Standard_DS2_v2'
        osType: 'Linux'
        mode: 'System'
      }
      {
        name: 'simulator'
        count: 1
        vmSize: 'Standard_B4ms'
        osType: 'Linux'
        mode: 'User'
        nodeLabels:{
          type: 'application'
        }
      }      
    ]
    linuxProfile: {
      adminUsername: adminusername
      ssh: {
        publicKeys: [
          {
            keyData: sshPubKey
          }
        ]
      }
    }
    identityProfile: {
      kubeletidentity:{
        resourceId: managedIdentity.id
        clientId: managedIdentity.properties.clientId
        objectId: managedIdentity.properties.principalId
      }
    }
    addonProfiles: !empty(logAnalyticId) ? {
      omsagent:{
        enabled: true 
        config: {
          logAnalyticsWorkspaceResourceID : logAnalyticId
        }       
      }
    } : null
  }
}

output aksclusterfqdn string = akscluster.properties.fqdn
output aksresourceid string = akscluster.id
output aksresourcename string = akscluster.name
