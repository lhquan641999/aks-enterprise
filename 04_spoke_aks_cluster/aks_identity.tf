resource "azurerm_user_assigned_identity" "identity_aks" {
  # count               = var.enable_aks_cluster ? 1 : 0
  name                = "identity-aks"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.resources_location
  tags                = var.tags
}

resource "azurerm_role_assignment" "role_identity_aks_network_contributor" {
  # count                            = var.enable_aks_cluster ? 1 : 0
  scope                            = data.terraform_remote_state.spoke_aks.outputs.vnet_spoke_aks.id
  role_definition_name             = "Network Contributor"
  principal_id                     = azurerm_user_assigned_identity.identity_aks.principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "role_identity_aks_mi_operator" {
  # count                            = var.enable_aks_cluster ? 1 : 0
  scope                            = azurerm_user_assigned_identity.identity-kubelet.id
  role_definition_name             = "Managed Identity Operator"
  principal_id                     = azurerm_user_assigned_identity.identity_aks.principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "role_identity_aks_contributor" {
  # count                            = var.enable_aks_cluster ? 1 : 0
  scope                            = azurerm_resource_group.rg.id
  role_definition_name             = "Contributor"
  principal_id                     = azurerm_user_assigned_identity.identity_aks.principal_id
  skip_service_principal_aad_check = true
}

# Assign Network Contributor to the API server subnet
# az role assignment create --scope <apiserver-subnet-resource-id> \
#     --role "Network Contributor" \
#     --assignee <managed-identity-client-id>
resource "azurerm_role_assignment" "role_identity_aks_network_contributor_subnet_apiserver" {
  count                            = var.enable_apiserver_vnet_integration ? 1 : 0
  scope                            = azurerm_subnet.subnet_apiserver.0.id
  role_definition_name             = "Network Contributor"
  principal_id                     = azurerm_user_assigned_identity.identity_aks.principal_id
  skip_service_principal_aad_check = true
}

# Role Assignments for Control Plane MSI
resource "azurerm_role_assignment" "role_identity_aks_contributor_routetable" {
  count                = var.enable_firewall_as_dns_server ? 1 : 0
  scope                = data.terraform_remote_state.spoke_aks.outputs.route_table.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.identity_aks.principal_id
}