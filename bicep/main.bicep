targetScope = 'resourceGroup'

@description('Location to deploy to')
param location string = resourceGroup().location
@description('Environment to deploy to')
param env string = 'dev'
@description('Service ID used in resource naming to group all related resources')
param serviceId string
param apimName string
param backendNames object = {
  backends: [
    {
      name: 'DEV'
      workflow: 'backend-writeblob-dev'
    }
    {
      name: 'Staging'
      workflow: 'backend-writeblob-staging'
    }    
  ]
}
param backendPoolMembers array

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
/*
module api 'modules/publishapi.bicep' = [for backend in backendNames.backends: {
  name: 'api-deploy-${backend.name}-${env}'
  params: {
    serviceId: serviceId
    apimName: apimName
    workflowName: backend.workflow
    siteLogicAppId: la.outputs.LogicAppSiteResourceId
    backendName: backend.name
  }
}
]

module apibackendpool 'modules/apibackendpool.bicep' = {
  name: 'apibackendpool-deploy-${env}'
  params: {
    serviceId: serviceId
    apimName: apimName
    backends: backendPoolMembers
  }
  dependsOn: [
    api
  ]
}
*/
