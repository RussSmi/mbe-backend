targetScope = 'resourceGroup'
param serviceId string
param apimName string
param workflowName string
param backendName string
param env string = 'dev'
param logicAppName string = 'la-${serviceId}-${env}'

func replaceMultiple(input string, replacements { *: string }) string => reduce(
  items(replacements), input, (cur, next) => replace(string(cur), next.key, next.value)
  )

resource apiManagementService 'Microsoft.ApiManagement/service@2023-03-01-preview' existing = {
  name: apimName
  scope: resourceGroup()
}

resource siteLogicApp 'Microsoft.Web/sites@2023-12-01' existing = {
  name: logicAppName
  scope: resourceGroup('rg-mbeback-test-uks')
}

var workflowUrl = listCallbackUrl('${siteLogicApp.id}/hostruntime/runtime/webhooks/workflow/api/management/workflows/${workflowName}/triggers/When_a_HTTP_request_is_received', '2023-12-01').value
var urlparts = split(workflowUrl, 'triggers/')

resource backends 'Microsoft.ApiManagement/service/backends@2023-09-01-preview' =  {
  name: '${serviceId}-${backendName}-backend'
  parent: apiManagementService
  properties: {
    url: '${urlparts[0]}triggers'
    protocol: 'http'
    description: 'Backend for ${workflowName}'
    type: 'Single'
    circuitBreaker: (backendName == 'Production' || backendName == 'DREC') ? {
      rules: [
        {
          acceptRetryAfter: true
          failureCondition: {
            count: 1
            interval: 'PT1M'
            statusCodeRanges: [
              {
                min: 500
                max: 503
              }
            ]
          }
          name: '${serviceId}-${workflowName}BreakerRule'
          tripDuration: 'PT1M'
        }
      ]
    } : null
  }
}

// Create API to access the logic app
resource api 'Microsoft.ApiManagement/service/apis@2023-03-01-preview' = {
  parent: apiManagementService
  name: workflowName
  properties: {
    displayName: workflowName
    subscriptionRequired: false
    path: backendName
    protocols: [
      'https'
    ]
  }
  dependsOn: [
    backends
  ]
}

resource operation 'Microsoft.ApiManagement/service/apis/operations@2023-09-01-preview' = {
  parent: api
  name: 'post'
  properties: {
    displayName: 'Trigger'
    method: 'POST'
    urlTemplate: '/'
    request: {
      queryParameters: []
      headers: []
    }
    responses: []
  }
}

var xmlPolicyContent = loadTextContent('./policies/setbackend.xml')
var replacedContent = replaceMultiple(xmlPolicyContent, {
  '***backendid***': (backendName == 'Production' || backendName == 'DREC') ? '${serviceId}pool' : backends.name
  '***urlpart2***': replace(urlparts[1], '&', '&amp;')
  '***id***': 'Id-${serviceId}-${backendName}'
  })

// Add xml policy to the operation
resource xmlPolicy 'Microsoft.ApiManagement/service/apis/operations/policies@2023-09-01-preview' = {
  parent: operation
  name: 'policy'
  properties: {
    format: 'xml'
    value: replacedContent
  }
}

output xmlPolicyContent string = xmlPolicyContent

