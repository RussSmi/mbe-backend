// Create a storage account and container for client messages
targetScope='resourceGroup'

@description('Location for all resources.')
param location string = resourceGroup().location

param env string = 'dev'  /// Use prod for production

resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: 'clistrg${env}${uniqueString(resourceGroup().id)}'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    allowSharedKeyAccess: true
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: storage
  name: 'default'
}

resource containerDev 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobService
  name: 'dev'
  properties: {
    publicAccess: 'None'
  }
}

resource containerStaging 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobService
  name: 'staging'
  properties: {
    publicAccess: 'None'
  }
}

resource containerSit 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobService
  name: 'sit'
  properties: {
    publicAccess: 'None'
  }
}

resource containerCft2 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobService
  name: 'cft2'
  properties: {
    publicAccess: 'None'
  }
}

resource containerTrain 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobService
  name: 'training'
  properties: {
    publicAccess: 'None'
  }
}

resource containerUat 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobService
  name: 'uat'
  properties: {
    publicAccess: 'None'
  }
}

resource containerDr 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobService
  name: 'drec'
  properties: {
    publicAccess: 'None'
  }
}

resource containerProd 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobService
  name: 'production'
  properties: {
    publicAccess: 'None'
  }
}

var blobStorageConnectionString  = 'https://${storage.name}.blob.core.windows.net/'

output storageConnectionString string = blobStorageConnectionString
output storageAccountName string = storage.name
