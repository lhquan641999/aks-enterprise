resource "azurerm_subnet" "subnet_shared" {
  name                 = "subnet-shared"
  resource_group_name  = azurerm_resource_group.rg_spoke_shared.name
  virtual_network_name = azurerm_virtual_network.vnet_spoke_shared.name
  address_prefixes     = var.cidr_subnet_shared
  service_endpoints    = ["Microsoft.Storage"]

  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_private_dns_zone" "mysql_flexible_server" {
  name                = "mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.rg_spoke_shared.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "link_mysql_vnet_shared" {
  name                  = "link_mysql_vnet_shared"
  private_dns_zone_name = azurerm_private_dns_zone.mysql_flexible_server.name
  virtual_network_id    = azurerm_virtual_network.vnet_spoke_shared.id
  resource_group_name   = azurerm_resource_group.rg_spoke_shared.name
}

resource "azurerm_mysql_flexible_server" "mysql_flexible_server" {
  name                   = "mysql-flexible-server-01357"
  resource_group_name    = azurerm_resource_group.rg_spoke_shared.name
  location               = azurerm_resource_group.rg_spoke_shared.location
  administrator_login    = "houssem"
  administrator_password = "@Aa123456789"
  backup_retention_days  = 7
  delegated_subnet_id    = azurerm_subnet.subnet_shared.id
  private_dns_zone_id    = azurerm_private_dns_zone.mysql_flexible_server.id
  sku_name               = "B_Standard_B1s" # "GP_Standard_D2ds_v4" # 
  version                = "8.0.21"         # "5.7"            # 
  zone                   = "1"
  tags                   = var.tags

  depends_on = [azurerm_private_dns_zone_virtual_network_link.link_mysql_vnet_shared]
}

resource "azurerm_mysql_flexible_database" "mysql_flexible_database" {
  name                = "mysqldb"
  resource_group_name = azurerm_mysql_flexible_server.mysql_flexible_server.resource_group_name
  server_name         = azurerm_mysql_flexible_server.mysql_flexible_server.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}
