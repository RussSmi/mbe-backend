targetScope = 'resourceGroup'
param serviceId string
param apimName string
param workflowName string
param siteLogicAppId string
param backendName string

resource apiManagementService 'Microsoft.ApiManagement/service@2023-03-01-preview' existing = {
  name: apimName
  scope: resourceGroup()
}

var workflowUrl = listCallbackUrl('${siteLogicAppId}/hostruntime/runtime/webhooks/workflow/api/management/workflows/${workflowName}/triggers/When_a_HTTP_request_is_received', '2023-12-01').value

resource backends 'Microsoft.ApiManagement/service/backends@2023-09-01-preview' =  {
  name: '${serviceId}-${workflowName}'
  parent: apiManagementService
  properties: {
    url: workflowUrl
    protocol: 'http'
    description: 'Backend for ${workflowName}'
    type: 'Single'
    circuitBreaker: (backendName == 'Production' || backendName == 'DR') ? {
      rules: [
        {
          acceptRetryAfter: true
          failureCondition: {
            count: 1
            interval: 'PT10S'
            statusCodeRanges: [
              {
                min: 400
                max: 429
              }
              {
                min: 500
                max: 503
              }
            ]
          }
          name: '${serviceId}-${workflowName}BreakerRule'
          tripDuration: 'PT10S'
        }
      ]
    } : null
  }
}


