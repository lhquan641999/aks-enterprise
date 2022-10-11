resource "azurerm_virtual_network" "vnet_spoke" {
  name                = var.vnet_spoke
  location            = var.resources_location
  resource_group_name = azurerm_resource_group.rg_spoke.name
  address_space       = var.cidr_vnet_spoke

  tags = var.tags
}

resource "azurerm_subnet" "subnet_nodes" {
  name                 = var.subnet_nodes
  virtual_network_name = azurerm_virtual_network.vnet_spoke.name
  resource_group_name  = azurerm_virtual_network.vnet_spoke.resource_group_name
  address_prefixes     = var.cidr_subnet_nodes
}

resource "azurerm_subnet" "subnet_pods" {
  name                 = var.subnet_pods
  virtual_network_name = azurerm_virtual_network.vnet_spoke.name
  resource_group_name  = azurerm_virtual_network.vnet_spoke.resource_group_name
  address_prefixes     = var.cidr_subnet_pods

  # src: https://github.com/hashicorp/terraform-provider-azurerm/blob/4ea5f92ccc27a75807d704f6d66d53a6c31459cb/internal/services/containers/kubernetes_cluster_node_pool_resource_test.go#L1433
  delegation {
    name = "aks-delegation"
    service_delegation {
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
      name = "Microsoft.ContainerService/managedClusters"
    }
  }
}

resource "azurerm_subnet" "subnet_appgw" {
  count                = var.enable_app_gateway ? 1 : 0
  name                 = var.subnet_app_gateway
  virtual_network_name = azurerm_virtual_network.vnet_spoke.name
  resource_group_name  = azurerm_virtual_network.vnet_spoke.resource_group_name
  address_prefixes     = var.cidr_subnet_appgateway
}

resource "azurerm_subnet" "subnet_apiserver" {
  count                = var.enable_apiserver_vnet_integration ? 1 : 0
  name                 = var.subnet_apiserver
  virtual_network_name = azurerm_virtual_network.vnet_spoke.name
  resource_group_name  = azurerm_virtual_network.vnet_spoke.resource_group_name
  address_prefixes     = var.subnet_apiserver_address_prefix

  delegation {
    name = "aks-delegation"
    service_delegation {
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
      name = "Microsoft.ContainerService/managedClusters"
    }
  }
}

resource "azurerm_subnet" "subnet_pe" {
  count                = var.enable_private_acr || var.enable_private_keyvault ? 1 : 0
  name                 = var.subnet_pe
  virtual_network_name = azurerm_virtual_network.vnet_spoke.name
  resource_group_name  = azurerm_virtual_network.vnet_spoke.resource_group_name
  address_prefixes     = var.cidr_subnet_pe
}

resource "azurerm_subnet" "subnet_bastion" {
  count                = var.enable_bastion ? 1 : 0
  name                 = var.subnet_bastion
  virtual_network_name = azurerm_virtual_network.vnet_spoke.name
  resource_group_name  = azurerm_virtual_network.vnet_spoke.resource_group_name
  address_prefixes     = var.cidr_subnet_bastion
}

resource "azurerm_subnet" "subnet_jumpbox" {
  count                = var.enable_vm_jumpbox_windows || var.enable_vm_jumpbox_linux ? 1 : 0
  name                 = var.subnet_jumpbox
  resource_group_name  = azurerm_virtual_network.vnet_spoke.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet_spoke.name
  address_prefixes     = var.cidr_subnet_jumpbox
}

resource "azurerm_monitor_diagnostic_setting" "diagnostic_settings_vnet" {
  count                      = var.enable_monitoring ? 1 : 0
  name                       = "diagnostic-settings"
  target_resource_id         = azurerm_virtual_network.vnet_spoke.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.0.id

  log {
    category = "VMProtectionAlerts"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = true
    }
  }
}