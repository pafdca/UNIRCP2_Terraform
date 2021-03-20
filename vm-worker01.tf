# Nodo worker de k8s worker01

# Creación de máquina virtual
resource "azurerm_linux_virtual_machine" "vm-worker01" {
    name                = "worker01.acme.es"
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    size                = var.worker_vm_size
    admin_username      = "useradmin"
    network_interface_ids = [ azurerm_network_interface.nic-worker01.id ]
    disable_password_authentication = true

    # Copia de clave pública SSH
    admin_ssh_key {
        username   = "useradmin"
        public_key = file("~/.ssh/id_rsa.pub")
    }

    # Almacenamiento con redundancia local estándar
    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    plan {
        name      = "centos-8-stream-free"
        product   = "centos-8-stream-free"
        publisher = "cognosys"
    }

    source_image_reference {
        publisher = "cognosys"
        offer     = "centos-8-stream-free"
        sku       = "centos-8-stream-free"
        version   = "1.2019.0810"
    }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.stAccount.primary_blob_endpoint
    }

    tags = {
        environment = "CP2"
    }

}
