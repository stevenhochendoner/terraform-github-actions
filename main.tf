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

data "azurerm_subnet" "corp" {
  name                 = "default"
  virtual_network_name = "CorporateResources-VNET"
  resource_group_name  = "VM-Corp-Rg"
}

#refer to a virtual network
data "azurerm_virtual_network" "corp" {
  virtual_network_name = "CorporateResources-VNET"
  resource_group_name = "VM-Corp-Rg"

}

# Create network interface
resource "azurerm_network_interface" "nic" {
  name                = "${var.windows_virtual_machine_name}-nic01"
  location            = data.azurerm_resource_group.corp.location
  resource_group_name = data.azurerm_resource_group.corp.name

}
# Define any Azure resources to be created here. A simple resource group is shown here as a minimal example.
resource "azurerm_resource_group" "steve-test-rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_windows_virtual_machine" "windowsvm" {
  name                  = var.windows_virtual_machine_name
  location              = var.location
  resource_group_name   = "steve-test-rg"
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = "Standard-B2s"
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
