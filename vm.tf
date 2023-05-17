# Création de disque de 20gb pour les vms  
   resource "azurerm_managed_disk" "test" {
   count                = 2
   name                 = "datadisk_existing_${count.index}"
   location             = azurerm_resource_group.test.location
   resource_group_name  = azurerm_resource_group.test.name
   storage_account_type = "Standard_LRS"
   create_option        = "Empty"
   disk_size_gb         = "1023"
 }

# Création d’un groupe de haute disponibilité
 resource "azurerm_availability_set" "avset" {
   name                         = "avset"
   location                     = azurerm_resource_group.test.location
   resource_group_name          = azurerm_resource_group.test.name
   platform_fault_domain_count  = 2
   platform_update_domain_count = 2
   managed                      = true
 }

# Création de 2 VM
 resource "azurerm_virtual_machine" "test" {
   count                 = 2
   name                  = "acctvm${count.index}"
   location              = azurerm_resource_group.test.location
   availability_set_id   = azurerm_availability_set.avset.id
   resource_group_name   = azurerm_resource_group.test.name
   network_interface_ids = [element(azurerm_network_interface.test.*.id, count.index)]
   vm_size               = "Standard_DS1_v2"

# Cette ligne permet de supprimer automatiquement le disk OS lors de la suppression de la VM
    delete_os_disk_on_termination = true

# Cette ligne permet de supprimer automatiquement le data disk lors de la suppression de la VM
    delete_data_disks_on_termination = true

# Le choix des images pour les VM's
   storage_image_reference {
     publisher = "Canonical"
     offer     = "UbuntuServer"
     sku       = "16.04-LTS"
     version   = "latest"
   }

# Type de disque pour l'OS
   storage_os_disk {
     name              = "myosdisk${count.index}"
     caching           = "ReadWrite"
     create_option     = "FromImage"
     managed_disk_type = "Standard_LRS"
   }

# Paramètres pour la connexion Admin
   os_profile {
     computer_name  = "mohamed"
     admin_username = "mohamed"
     admin_password = "mohamed123!"
   }

   os_profile_linux_config {
     disable_password_authentication = false
   }

   tags = {
     environment = "staging"
   }
 }
