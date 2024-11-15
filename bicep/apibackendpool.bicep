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

resource apiManagementService 'Microsoft.ApiManagement/service@2023-03-01-preview' existing = {
  name: apimName
  scope: resourceGroup()
}

resource mbebpool 'Microsoft.ApiManagement/service/backends@2023-09-01-preview' = {
  name: '${serviceId}pool'
  parent: apiManagementService
  properties: {
    description: 'Load balance openai instances'
    type: 'Pool'
    protocol: 'http'
    url: 'https://' //Not required for pool type
    pool: {
      services: [
        {
          id: '/backends/${serviceId}-production-backend'
          priority: 1
          weight: 1
        }
        {
          id: '/backends/${serviceId}-UAT-backend}'
          priority: 2
          weight: 1
        }

      ]
    }
  }
}
