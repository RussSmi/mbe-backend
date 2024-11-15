using './apibackendpool.bicep'

param serviceId = 'mbebackend'
param apimName = 'apim-aisv31-dev'
param backendNames = {
  backends: [
    {
      name: 'DEV'
      workflow: 'backend-writeblob-dev'
    }
    {
      name: 'Staging'
      workflow: 'backend-writeblob-staging'
    }
    {
      name: 'SIT'
      workflow: 'backend-writeblob-sit'
    }
    {
      name: 'CFT2'
      workflow: 'backend-writeblob-cft2'
    }
    {
      name: 'Training'
      workflow: 'backend-writeblob-training'
    }
    {
      name: 'UAT'
      workflow: 'backend-writeblob-uat'
    }
    {
      name: 'DREC'
      workflow: 'backend-writeblob-drec'
    }
    {
      name: 'Production'
      workflow: 'backend-writeblob-production'
    }
  ]
}

