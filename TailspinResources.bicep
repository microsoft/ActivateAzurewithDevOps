
param websiteName string = 'tailspin123'
param hostingPlanName string = 'tailspindemo'
param location string = resourceGroup().location

//create the app service plan
resource appServicePlan 'Microsoft.Web/serverFarms@2020-06-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: 'S1'
    tier: 'Standard'
  }
}

//create the app service
resource appServiceApp 'Microsoft.Web/sites@2020-06-01' = {
  name: websiteName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    ftpsState: 'FtpsOnly'
    siteConfig: {
      minTlsVersion: '1.2'
    }
  }
}

//create the app service slots
resource devSlot 'Microsoft.Web/sites/slots@2016-08-01' = {
  name: '${appServiceApp.name}/dev'
  location: location
  kind: 'appService'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
  }
}

resource stagingSlot 'Microsoft.Web/sites/slots@2016-08-01' = {
  name: '${appServiceApp.name}/staging'
  location: location
  kind: 'appService'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
  }

}

//create the app insights
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: websiteName
  location: location
  kind: 'web'
  tags: {
    'hidden-link:${appServiceApp.id}': 'Resource'
    displayName: 'AppInsightsComponent'
  }
  properties: {
    Application_Type: 'web'
  }

}

resource appInsightsDev 'Microsoft.Insights/components@2020-02-02' = {
  name: '${websiteName}-dev'
  location: location
  kind: 'web'
  tags: {
    'hidden-link:${devSlot.id}': 'Resource'
    displayName: 'AppInsightsComponent'
  }
  properties: {
    Application_Type: 'web'
  }

}

resource appInsightsStaging 'Microsoft.Insights/components@2020-02-02' = {
  name: '${websiteName}-staging'
  location: location
  kind: 'web'
  tags: {
    'hidden-link:${stagingSlot.id}': 'Resource'
    displayName: 'AppInsightsComponent'
  }
  properties: {
    Application_Type: 'web'
  }

}

