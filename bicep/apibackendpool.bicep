targetScope = 'resourceGroup'
param serviceId string
param apimName string
param env string = 'dev'
param logicAppName string = 'la-${serviceId}-${env}'
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


module publishapi 'modules/publishapi.bicep' = [for backend in backendNames.backends: {
  name: 'api-deploy-${backend.name}-${env}'
  params: {
    serviceId: serviceId
    apimName: apimName
    workflowName: backend.workflow
    backendName: backend.name
    logicAppName: logicAppName
  }
}]

module backendpool 'modules/backendpool.bicep' = {
  name: 'backendpool-deploy-${env}'
  scope: resourceGroup('rg-apim-aisv31-dev')
   params: {
    apimName: apimName
    serviceId: serviceId
  }
  dependsOn: [
    publishapi
  ]
}

