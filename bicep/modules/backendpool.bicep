targetScope = 'resourceGroup'
param apimName string
param serviceId string

resource apiManagementService 'Microsoft.ApiManagement/service@2023-03-01-preview' existing = {
  name: apimName
  scope: resourceGroup()
}

resource mbebpool 'Microsoft.ApiManagement/service/backends@2024-05-01' = {
  name: '${serviceId}pool'
  parent: apiManagementService
  properties: {
    description: 'Load balance backend instances'
    type: 'Pool'
    pool: {
      services: [
        {
          id: '/backends/${serviceId}-production-backend'
          priority: 1
          weight: 1
        }
        {
          id: '/backends/${serviceId}-DREC-backend'
          priority: 2
          weight: 1
        }

      ]
    }
  }
}
