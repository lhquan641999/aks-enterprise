# resource azurerm_log_analytics_workspace workspace {
# #   count = var.enable_monitoring || var.enable_diagnostic_settings ? 1 : 0
#   provider            = azurerm.subscription_hub
#   name                = var.log_analytics_workspace
#   resource_group_name = azurerm_resource_group.rg_hub.name
#   location            = var.resources_location
#   sku                 = "PerGB2018" # PerGB2018, Free, PerNode, Premium, Standard, Standalone, Unlimited, CapacityReservation
#   retention_in_days   = 30          # possible values are either 7 (Free Tier only) or range between 30 and 730
#   tags                = var.tags
# }

# resource azurerm_log_analytics_solution solution {
# #   count = var.enable_monitoring || var.enable_diagnostic_settings ? 1 : 0
#   provider              = azurerm.subscription_hub
#   solution_name         = "ContainerInsights"
#   location              = azurerm_log_analytics_workspace.workspace.location
#   resource_group_name   = azurerm_log_analytics_workspace.workspace.resource_group_name
#   workspace_resource_id = azurerm_log_analytics_workspace.workspace.id
#   workspace_name        = azurerm_log_analytics_workspace.workspace.name
#   tags                  = var.tags

#   plan {
#     publisher = "Microsoft"
#     product   = "OMSGallery/ContainerInsights"
#   }
# }

# output "log_analytics_workspace_id" {
#   value = azurerm_log_analytics_workspace.workspace.id
# }