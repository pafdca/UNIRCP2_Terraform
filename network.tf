# Creación de la vnet
resource "azurerm_virtual_network" "vnet-mynet" {
    name                = "vnet-k8s"
    address_space       = ["192.168.0.0/16"]
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    tags = {
        environment = "CP2"
    }
}

# Creación de la subnet
resource "azurerm_subnet" "snet-k8s" {
    name                   = "terraformsubnet"
    resource_group_name    = azurerm_resource_group.rg.name
    virtual_network_name   = azurerm_virtual_network.vnet-mynet.name
    address_prefixes       = ["192.168.1.0/24"]

}

# Creación de NICs

# NIC para máquina master
resource "azurerm_network_interface" "nic-master" {
  name                = "nic-master"  
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
    name                           = "ip-master"
    subnet_id                      = azurerm_subnet.snet-k8s.id 
    private_ip_address_allocation  = "Static"
    private_ip_address             = "192.168.1.110"
  }

    tags = {
        environment = "CP2"
    }

}

# NIC para máquina worker01
resource "azurerm_network_interface" "nic-worker01" {
  name                = "nic-worker01"  
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
    name                           = "ip-worker01"
    subnet_id                      = azurerm_subnet.snet-k8s.id 
    private_ip_address_allocation  = "Static"
    private_ip_address             = "192.168.1.111"
  }

    tags = {
        environment = "CP2"
    }

}

# NIC para máquina worker02
resource "azurerm_network_interface" "nic-worker02" {
  name                = "nic-worker02"  
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
    name                           = "ip-worker02"
    subnet_id                      = azurerm_subnet.snet-k8s.id 
    private_ip_address_allocation  = "Static"
    private_ip_address             = "192.168.1.112"
  }

    tags = {
        environment = "CP2"
    }

}

# NIC para máquina nfs
resource "azurerm_network_interface" "nic-nfs" {
  name                = "nic-nfs"  
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
    name                           = "ip-nfs"
    subnet_id                      = azurerm_subnet.snet-k8s.id 
    private_ip_address_allocation  = "Static"
    private_ip_address             = "192.168.1.115"
  }

    tags = {
        environment = "CP2"
    }

}

# NIC para máquina controller
resource "azurerm_network_interface" "nic-controller" {
  name                = "nic-controller"  
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
    name                           = "ip-controller"
    subnet_id                      = azurerm_subnet.snet-k8s.id 
    private_ip_address_allocation  = "Static"
    private_ip_address             = "192.168.1.116"
    # IP pública para conexión con Controller de Ansible
    public_ip_address_id           = azurerm_public_ip.pubip-controller.id
  }

    tags = {
        environment = "CP2"
    }

}

# Definición de IP pública para nodo controller
# Se utilizará este acceso para lanzar los playbooks de ansible
resource "azurerm_public_ip" "pubip-controller" {
  name                = "pubip-controller"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
  sku                 = "Basic"
  # Label para la definición de dominio, se utilizará
  # para la ejecución de comandos remota con terraform
  domain_name_label   = "unircp2controller"

    tags = {
        environment = "CP2"
    }

}
