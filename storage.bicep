resource sa 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: 'storageapi${uniqueString(resourceGroup().id)}'
  kind: 'StorageV2'
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    supportsHttpsTrafficOnly: true
    defaultToOAuthAuthentication: true
  }
}

output storageName string = sa.name
