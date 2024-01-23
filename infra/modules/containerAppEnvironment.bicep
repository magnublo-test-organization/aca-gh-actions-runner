param location string
param project string
param tags {
  *: string
}
param lawName string
param subnetId string

resource law 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: lawName
}

resource acaEnv 'Microsoft.App/managedEnvironments@2023-05-01' = {
  name: 'cae-${project}'
  location: location
  tags: tags
  properties: {
    workloadProfiles: [
      {
        name: 'Consumption'
        workloadProfileType: 'Consumption'
      }
    ]
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: law.properties.customerId
        sharedKey: law.listKeys().primarySharedKey
      }
    }
    // vnetConfiguration is included if subnetId is non-empty
    vnetConfiguration: empty(subnetId) ? {} : {
      infrastructureSubnetId: subnetId
      internal: true
    }
  }
}

output acaEnvName string = acaEnv.name

// debugging outputs
output acaEnvSubnetId string = empty(subnetId) ? 'emptySubnetId' : acaEnv.properties.vnetConfiguration.infrastructureSubnetId
// output vnetConfiguration (object | null) = acaEnv.properties.vnetConfiguration
output vnetConfigurationIf object = empty(subnetId) ? {} : {
  infrastructureSubnetId: subnetId
  internal: true
}
