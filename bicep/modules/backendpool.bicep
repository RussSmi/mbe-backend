targetScope = 'resourceGroup'
param apimName string
param serviceId string

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