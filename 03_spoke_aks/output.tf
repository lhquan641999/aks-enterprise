output "vnet_spoke_aks" {
  value = {
    virtual_network_name = azurerm_virtual_network.vnet_spoke_aks.name
    resource_group_name  = azurerm_virtual_network.vnet_spoke_aks.resource_group_name
    id                   = azurerm_virtual_network.vnet_spoke_aks.id
  }
}

output "acr" {
  value = {
    id = azurerm_container_registry.acr.id
  }
}

output "application_gateway" {
  value = {
    enabled = var.enable_app_gateway
    id      = azurerm_application_gateway.appgw.0.id
  }
}

output "grafana_endpoint" {
  value = var.enable_grafana_prometheus ? azurerm_dashboard_grafana.grafana_aks.0.endpoint : null
}
