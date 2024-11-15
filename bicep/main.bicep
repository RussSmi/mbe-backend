targetScope = 'resourceGroup'

@description('Location to deploy to')
param location string = resourceGroup().location
@description('Environment to deploy to')
param env string = 'dev'
@description('Service ID used in resource naming to group all related resources')
param serviceId string


module storage 'modules/storage.bicep' = {
  name: 'storage-deploy-${env}'
  params: {
    location: location
    env: env
  }
}

module la 'modules/logicapp.bicep' = {
  name: 'la-deploy-${env}'
  params: {
    env: env
    location: location
    serviceId: serviceId
    backendStorageConnectionString: storage.outputs.storageConnectionString
    backendStorageAccountName: storage.outputs.storageAccountName
  }
}
