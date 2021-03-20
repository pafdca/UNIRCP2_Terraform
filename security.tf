# Security groups
resource "azurerm_network_security_group" "mySecGroup" {
    name                = "sshtraffic"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
	
    # Habilitación de tráfico SSH
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "CP2"
    }
}

# Vinculación de security group al interface de red de máquina master
resource "azurerm_network_interface_security_group_association" "SecGroupAssociationMaster" {
    network_interface_id      = azurerm_network_interface.nic-master.id
    network_security_group_id = azurerm_network_security_group.mySecGroup.id

}

# Vinculación de security group al interface de red de máquina worker01
resource "azurerm_network_interface_security_group_association" "SecGroupAssociationWorker01" {
    network_interface_id      = azurerm_network_interface.nic-worker01.id
    network_security_group_id = azurerm_network_security_group.mySecGroup.id

}

# Vinculación de security group al interface de red de máquina worker02
resource "azurerm_network_interface_security_group_association" "SecGroupAssociationWorker02" {
    network_interface_id      = azurerm_network_interface.nic-worker02.id
    network_security_group_id = azurerm_network_security_group.mySecGroup.id
}

# Vinculación de security group al interface de red de máquina nfs
resource "azurerm_network_interface_security_group_association" "SecGroupAssociationNFS" {
    network_interface_id      = azurerm_network_interface.nic-nfs.id
    network_security_group_id = azurerm_network_security_group.mySecGroup.id
}

# Vinculación de security group al interface de red de máquina controller de ansible
resource "azurerm_network_interface_security_group_association" "SecGroupAssociationAnsible" {
    network_interface_id      = azurerm_network_interface.nic-controller.id
    network_security_group_id = azurerm_network_security_group.mySecGroup.id
}
