param location string = resourceGroup().location
param project string

param acrName string
param acaEnvName string
param imageTag string

@secure()
param gitHubAccessToken string
param gitHubOrganization string
param gitHubAppId string
param keyVaultUrl string
param keyVaultPrivateKeySecretName string

param useJobs bool = true
param runnerLabels string

var runnerLabelsArg = empty(runnerLabels) ? '' : '--labels ${runnerLabels}'

module acj '../modules/containerAppJob.bicep' = if (useJobs) {
  name: 'deploy-${project}-acj'
  params: {
    acaEnvironmentName: acaEnvName
    acrName: acrName
    gitHubAccessToken: gitHubAccessToken
    gitHubOrganization: gitHubOrganization
    imageTag: imageTag
    location: location
    project: project
    tags: union(resourceGroup().tags, { module: 'containerAppJob.bicep' })
    runnerLabelsArg: runnerLabelsArg
    gitHubAppId: gitHubAppId
    keyVaultUrl: keyVaultUrl
    keyVaultPrivateKeySecretName: keyVaultPrivateKeySecretName
  }
}

module aca '../modules/containerApp.bicep' = if (!useJobs) {
  name: 'deploy-${project}-aca'
  params: {
    acaEnvironmentName: acaEnvName
    acrName: acrName
    gitHubAccessToken: gitHubAccessToken
    gitHubOrganization: gitHubOrganization
    imageTag: imageTag
    location: location
    project: project
    tags: union(resourceGroup().tags, { module: 'containerApp.bicep' })
    runnerLabelsArg: runnerLabelsArg
  }
}
