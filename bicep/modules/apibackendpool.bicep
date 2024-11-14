param serviceId string
param apimName string
param backends array

resource apiManagementService 'Microsoft.ApiManagement/service@2023-03-01-preview' existing = {
  name: apimName
  scope: resourceGroup()
}

resource aoailbpool 'Microsoft.ApiManagement/service/backends@2023-09-01-preview' = {
  name: '${serviceId}pool'
  parent: apiManagementService
  properties: {
    description: 'Load balance openai instances'
    type: 'Pool'
    protocol: 'http'
    url: 'https://api.openai.com'
    pool: {
      services: [
        {
          id: '/backends/${backends[0]}'
          priority: 1
          weight: 1
        }
        {
          id: '/backends/${backends[1]}'
          priority: 2
          weight: 1
        }

      ]
    }
  }
}
