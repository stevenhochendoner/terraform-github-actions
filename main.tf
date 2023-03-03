terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0"
    }
  }

  # Update this block with the location of your terraform state file
  backend "azurerm" {
    resource_group_name  = "VM-Corp-Rg"
    storage_account_name = "terraformcorp"
    container_name       = "terracorpcontainer"
    key                  = "terraform.tfstate"
    use_oidc             = true
  }
}

provider "azurerm" {
  features {}
  use_oidc = true
}

# Define any Azure resources to be created here. A simple resource group is shown here as a minimal example.
resource "azurerm_resource_group" "steve-test-rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_windows_virtual_machine" "windowsvm" {
  name                  = var.windows_virtual_machine_name
  location              = var.location
  resource_group_name   = azurerm_resource_group.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = var.vm_size
  admin_username        = "spadmin"
  admin_password        = "$phere2023!"
  computer_name         = var.vm_hostname

  os_disk  {
    name                 = "${var.windows_virtual_machine_name}_os_disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter-Azure-Edition"
    version   = "latest"
  }
}
