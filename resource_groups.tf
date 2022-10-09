resource "azurerm_resource_group" "rg_hub" {
  provider = azurerm.subscription_hub
  name     = var.rg_hub
  location = var.resources_location

  tags = var.tags
}

resource "azurerm_resource_group" "rg_spoke" {
  name     = var.rg_spoke
  location = var.resources_location

  tags = var.tags
}

resource "azurerm_resource_group" "rg_spoke_vm" {
  count    = var.enable_vm_jumpbox_windows || var.enable_vm_jumpbox_linux ? 1 : 0
  name     = var.rg_spoke_vm
  location = var.resources_location

  tags = var.tags
}

resource "azurerm_resource_group" "rg_aks" {
  name     = var.rg_aks
  location = var.resources_location

  tags = var.tags
}
