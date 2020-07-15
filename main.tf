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
    address_prefixes = ["10.0.1.0/24"]

}

resource "azurerm_public_ip" "pip" {
    name = "testingpip01"
    resource_group_name = azurerm_resource_group.rges.name
    sku = "Standard"
    #sku = "Basic"
    allocation_method = "Static"
    location = azurerm_resource_group.rges.location    

    tags = {
        Environment = "SANDBOX"
        Buildby = "Rahul Sharma"
        Builddate = "15-07-2020"
           }
}

resource "azurerm_lb" "lb" {
    name = "testinglb"
    location = azurerm_resource_group.rges.location
    resource_group_name =azurerm_resource_group.rges.name
    sku = "Standard"
    #sku = "Basic"

frontend_ip_configuration {
    name = "publicfront"
    public_ip_address_id =  azurerm_public_ip.pip.id
}
   }

resource "azurerm_lb_backend_address_pool" "backpool" {
 resource_group_name = azurerm_resource_group.rges.name
 loadbalancer_id     = azurerm_lb.lb.id
 name                = "backendpool"
}

resource "azurerm_lb_rule" "lbrule" {
  resource_group_name            = azurerm_resource_group.rges.name
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 3389
  backend_port                   = 3389
  frontend_ip_configuration_name = "publicfront"
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

resource "azurerm_availability_set" "avset" {
 name                         = "avset"
 location                     = azurerm_resource_group.rges.location
 resource_group_name          = azurerm_resource_group.rges.name
 platform_fault_domain_count  = 2
 platform_update_domain_count = 5
 managed                      = true
}

resource "azurerm_windows_virtual_machine" "vm" {
    count = 2
    name = "testingvm${count.index}"
    availability_set_id = azurerm_availability_set.avset.id
    resource_group_name = azurerm_resource_group.rges.name
    location = azurerm_resource_group.rges.location
    size = "Standard_F2"
    admin_username      = "adminuser"
    admin_password      = "Welcome@12345"
    network_interface_ids = [element(azurerm_network_interface.nic.*.id,count.index)]
    
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

#--- if you need datadisk un-comment below with required count can be changed
#resource "azurerm_managed_disk" "datadisk" {
 #count                = 2
 #name                 = "datadisk_${count.index}"
 #location             = azurerm_resource_group.rges.location
 #resource_group_name  = azurerm_resource_group.rges.name
 #storage_account_type = "Standard_LRS"
 #create_option        = "Empty"
 #disk_size_gb         = "1023"
#}



