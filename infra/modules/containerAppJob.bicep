param location string
param project string
param tags {
  *: string
}

param acrName string
param acaEnvironmentName string
@allowed([ '0.25', '0.5', '0.75', '1.0', '1.25', '1.5', '1.75', '2.0' ])
param containerCpu string = '0.25'
@allowed([ '0.5Gi', '1.0Gi', '1.5Gi', '2.0Gi', '2.5Gi', '3.0Gi', '3.5Gi', '4.0Gi' ])
param containerMemory string = '0.5Gi'
param imageTag string
param runnerLabelsArg string
param keyVaultUrl string

@secure()
param gitHubAccessToken string
param gitHubOrganization string
param gitHubAppId string

resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: acrName
}

resource acaEnv 'Microsoft.App/managedEnvironments@2023-05-01' existing = {
  name: acaEnvironmentName
}

resource acaMsi 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'id-${project}'
  location: location
}

var acrPullId = '7f951dda-4ed3-4680-a7ca-43fe172d538d'
resource acaAcrPull 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(acaMsi.id, acr.id, acrPullId)
  scope: acr
  properties: {
    principalId: acaMsi.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', acrPullId)
    principalType: 'ServicePrincipal'
  }
}

resource acaJob 'Microsoft.App/jobs@2023-05-01' = {
  name: 'caj-${project}'
  location: location
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${acaMsi.id}': {}
    }
  }
  properties: {
    environmentId: acaEnv.id
    configuration: {
      registries: [
        {
          server: acr.properties.loginServer
          identity: acaMsi.id
        }
      ]
      secrets: [
        {
          name: 'github-access-token'
          value: gitHubAccessToken
        }
        {
          name: 'github-app-base64-private-key'
          keyVaultUrl: keyVaultUrl
          identity: acaMsi.id
        }
      ]
      replicaTimeout: 1800
      triggerType: 'Event'
      eventTriggerConfig: {
        scale: {
          rules: [
            {
              name: 'github-runner-scaling-rule'
              type: 'github-runner'
              auth: [
                {
                  triggerParameter: 'personalAccessToken'
                  secretRef: 'github-access-token'
                }
              ]
              metadata: {
                owner: gitHubOrganization
                runnerScope: 'org'
              }
            }
          ]
        }
      }
    }
    template: {
      volumes: [
        {
          name: 'shared'
          storageType: 'EmptyDir'
        }
      ]
      initContainers: [
        {
          name: 'get-github-token'
          image: '${acr.properties.loginServer}/github-token-generator:latest'
          resources: {
            cpu: json(containerCpu)
            memory: containerMemory
          }
          // command: [
          //   '/bin/sh'
          //   '-c'
          //   'jwt encode --exp=600 --iss \${GH_APP_ID} --secret b64:\${BASE64_PRIVATE_KEY} > \${TOKEN_FILE}'
          // ]
          volumeMounts: [
            {
              volumeName: 'shared'
              mountPath: '/mnt/shared'
            }
          ]
          env: [
            {
              name: 'TOKEN_FILE'
              value: '/mnt/shared/token.jwt'
            }
            {
              name: 'GH_APP_ID'
              value: gitHubAppId
            }
            {
              name: 'BASE64_PRIVATE_KEY'
              secretRef: 'github-app-base64-private-key'
            }
          ]
        }
      ]
      containers: [
        {
          volumeMounts: [
            {
              volumeName: 'shared'
              mountPath: '/mnt/shared'
            }
          ]
          name: 'github-runner'
          image: '${acr.properties.loginServer}/runners/github/linux:${imageTag}'
          resources: {
            cpu: json(containerCpu)
            memory: containerMemory
          }
          env: [
            {
              name: 'TOKEN_FILE'
              value: '/mnt/shared/token.jwt'
            }
            {
              name: 'RUNNER_SCOPE'
              value: 'org'
            }
            {
              name: 'ORG_NAME'
              value: gitHubOrganization
            }
            {
              // Remove this once https://github.com/microsoft/azure-container-apps/issues/502 is fixed
              name: 'APPSETTING_WEBSITE_SITE_NAME'
              value: 'az-cli-workaround'
            }
            {
              name: 'MSI_CLIENT_ID'
              value: acaMsi.properties.clientId
            }
            {
              name: 'EPHEMERAL'
              value: '1'
            }
            {
              name: 'RUNNER_NAME_PREFIX'
              value: project
            }
            {
              name: 'RUNNER_LABELS'
              value: runnerLabelsArg
            }
          ]
        }
      ]
    }
  }

  dependsOn: [
    acaAcrPull
  ]
}
