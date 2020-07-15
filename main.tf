provider "azurerm" {
    features {}
}


resource "azurerm_resource_group" "rges" {
    name = "ES-US-VNET"
    location = "East US"
    tags = {
        Environment = "SANDBOX"
        Buildby = "Rahul Sharma"
        Builddate = "15-07-2020"
    }
}



resource "azurerm_virtual_network" "vnet" {
    name = "testingvnet"
    location = "East US"
    resource_group_name = azurerm_resource_group.rges.name
    address_space = ["10.0.0.0/16"]
    tags = {
        Environment = "SANDBOX"
        Buildby = "Rahul Sharma"
        Builddate = "15-07-2020"
           }
}
resource "azurerm_subnet" "subnetv1" {
    name = "testingsubnet01"
    resource_group_name = azurerm_resource_group.rges.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefix = "10.0.1.0/24"

}

resource "azurerm_public_ip" "pip" {
    name = "testingpip01"
    resource_group_name = azurerm_resource_group.rges.name
    allocation_method = "Dynamic"
    location = azurerm_resource_group.rges.location    

    tags = {
        Environment = "SANDBOX"
        Buildby = "Rahul Sharma"
        Builddate = "15-07-2020"
           }
}

resource "azurerm_network_interface" "nic" {
    count = 2
    name = "testingnic${count.index}"
    resource_group_name = azurerm_resource_group.rges.name
    location  = azurerm_resource_group.rges.location

    ip_configuration {
        name = "testingconfig"
        private_ip_address_allocation= "Dynamic"
        subnet_id = azurerm_subnet.subnetv1.id
    }
}

resource "azurerm_windows_virtual_machine" "vm" {
    count = 2
    name = "testingvm${count.index}"
    resource_group_name = azurerm_resource_group.rges.name
    location = azurerm_resource_group.rges.location
    size = "Standard_F2"
    admin_username      = "adminuser"
    admin_password      = "Welcome@12345"
    network_interface_ids = [azurerm_network_interface.nic.*.id,count.index]

tags = {
        Environment = "SANDBOX"
        Buildby = "Rahul Sharma"
        Builddate = "15-07-2020"
           }

    os_disk {
    name            = "osdisk${count.index}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}


