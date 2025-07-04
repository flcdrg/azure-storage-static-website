@description('Name of the storage account')
param storageAccountName string

@description('Location for the storage account')
param location string = resourceGroup().location

@description('Storage account SKU')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_ZRS'
  'Premium_LRS'
])
param storageSku string = 'Standard_LRS'

@description('Storage account kind')
@allowed([
  'Storage'
  'StorageV2'
  'BlobStorage'
])
param storageKind string = 'StorageV2'

@description('Enable static website hosting')
param enableStaticWebsite bool = true

@description('Index document name for static website')
param indexDocument string = 'index.html'

@description('Error document name for static website')
param errorDocument404Path string = 'error.html'

@description('Tags to apply to the storage account')
param tags object = {}

// Create the storage account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageSku
  }
  kind: storageKind
  properties: {
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: true
    minimumTlsVersion: 'TLS1_2'
    publicNetworkAccess: 'Enabled'
    allowSharedKeyAccess: true
    defaultToOAuthAuthentication: false
    accessTier: 'Hot'
  }
  tags: tags
}

// Enable static website hosting if requested
resource staticWebsite 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = if (enableStaticWebsite) {
  parent: storageAccount
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      enabled: false
    }
  }
}

// Configure static website
resource staticWebsiteConfig 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = if (enableStaticWebsite) {
  parent: staticWebsite
  name: '$web'
  properties: {
    publicAccess: 'None'
  }
}

// Output important information
output storageAccountName string = storageAccount.name
output storageAccountId string = storageAccount.id
output primaryEndpoints object = storageAccount.properties.primaryEndpoints
output staticWebsiteUrl string = enableStaticWebsite ? storageAccount.properties.primaryEndpoints.web : ''
