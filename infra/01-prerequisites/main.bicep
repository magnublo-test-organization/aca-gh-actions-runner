targetScope = 'subscription'

@minLength(1)
@description('Primary location for all resources')
param location string
param subnetId string = ''
param resourceGroupName string

var project = 'aca-gh-runners'

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
}

module resources 'resources.bicep' = {
  scope: rg
  name: 'deploy-${project}-prerequisites-resources'

  params: {
    location: location
    tags: {}
    project: project
    subnetId: subnetId
  }
}

output project string = project
output acrName string = resources.outputs.acrName
output acaEnvName string = resources.outputs.acaEnvName
output rgName string = rg.name
