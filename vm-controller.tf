# Desde esta máquina se lanzan automáticamente los playbooks de ansible

# Creación de la máquina virtual
resource "azurerm_linux_virtual_machine" "vm-controller" {
    name                = "controller.acme.es"
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    size                = var.controller_vm_size
    admin_username      = "useradmin"
    network_interface_ids = [ azurerm_network_interface.nic-controller.id ]
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

    # Copia de clave privada para conexión desde el controller
    provisioner "file" {
        connection {
            type     = "ssh"
            host     = "unircp2controller.westeurope.cloudapp.azure.com"
            user     = "useradmin"
            private_key = "${file("~/.ssh/id_rsa")}"
        }
        source      = "~/.ssh/id_rsa"
        destination = "/home/useradmin/.ssh/id_rsa"
  }

    # Copia de archivo de configuracion de ansible
    provisioner "file" {
        connection {
            type     = "ssh"
            host     = "unircp2controller.westeurope.cloudapp.azure.com"
            user     = "useradmin"
            private_key = "${file("~/.ssh/id_rsa")}"
        }
        source      = "~/.ansible.cfg"
        destination = "/home/useradmin/.ansible.cfg"
    }

    # Comandos para la ejecución de ansible desde el controller
    provisioner "remote-exec" {
        connection {
          type        = "ssh"
          host        = "unircp2controller.westeurope.cloudapp.azure.com"
          user        = "useradmin"
	  private_key = "${file("~/.ssh/id_rsa")}"
        }
        inline     = [
			# Permisos para clave pública
			"chmod 600 /home/useradmin/.ssh/id_rsa",
			# Instalación de repositorios
			"sudo dnf install epel-release -y",
			# Instalación de Ansible
			"sudo dnf install ansible -y",
			# Instalación de Git
			"sudo dnf install git -y",
			# Descarga de playbooks desde repositorio GitHub personal
			"git clone https://github.com/pafdca/UNIRCP2_Ansible.git",
			# Instalación de k8s mediante script que lanza los playbooks
			"UNIRCP2_Ansible/k8s_install.sh",
		     ]
    }

    tags = {
        environment = "CP2"
    }

}
