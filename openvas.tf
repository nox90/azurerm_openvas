resource "azurerm_resource_group" "openvas-rg" {
    location = var.location
    name     = "${var.environment_name}-openvas-rg"
    tags     = {}

    timeouts {}
}


resource "azurerm_virtual_machine" "openvas-vm" {
    depends_on = [
      azurerm_resource_group.openvas-rg
    ]
    location = var.location
    resource_group_name = azurerm_resource_group.openvas-rg.name 
    name                  = "${var.environment_name}-rg"
    network_interface_ids = [azurerm_network_interface.openvas-vm-interface.id,]
    tags                  = {}
    vm_size               = var.machine_size
    zones                 = []


    os_profile {
        admin_username = var.admin_username
        computer_name  = "${var.environment_name}-openvas-vm"
    }

    os_profile_linux_config {
        disable_password_authentication = true

        ssh_keys {
            key_data = var.ssh_key
            path     = "/home/azureuser/.ssh/authorized_keys"
        }


    }

    storage_image_reference {
        offer     = "UbuntuServer"
        publisher = "Canonical"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    storage_os_disk {
        caching                   = "ReadWrite"
        create_option             = "FromImage"
        disk_size_gb              = 30
        managed_disk_type         = "Standard_LRS"
        name                      = "${var.environment_name}-openvas-disk"
        os_type                   = "Linux"
        write_accelerator_enabled = false
    }
    boot_diagnostics {
        enabled = false
        storage_uri = ""
    }
    
    timeouts {}
    
    
}

resource "azurerm_network_interface" "openvas-vm-interface" {
    location = azurerm_resource_group.openvas-rg.location
    resource_group_name = azurerm_resource_group.openvas-rg.name
    name = "openvas-vm-interface"
    ip_configuration {
        name                          = "ipconfig1"
        primary                       = true
        private_ip_address            = var.vm_ip_address
        private_ip_address_allocation = "Dynamic"
        private_ip_address_version    = "IPv4"
        public_ip_address_id          = azurerm_public_ip.openvas-vm-ip.id
        subnet_id = azurerm_subnet.openvas-rg-subnet.id
    }

}

resource "azurerm_public_ip" "openvas-vm-ip" {
    allocation_method       = "Dynamic"
    idle_timeout_in_minutes = 4
    ip_version              = "IPv4"
    location = var.location
    name                    = "${var.environment_name}-openvas-vm-ip"
    resource_group_name = azurerm_resource_group.openvas-rg.name
    sku                     = "Basic"
    tags                    = {}


    timeouts {}
}

resource "azurerm_virtual_network" "openvas-rg-vnet" {
    location = azurerm_resource_group.openvas-rg.location
    resource_group_name = azurerm_resource_group.openvas-rg.name

    address_space       = var.address_space
    name                = "${var.environment_name}-openvas-rg-vnet"

    tags                = {}

    timeouts {}
}

resource "azurerm_subnet" "openvas-rg-subnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.openvas-rg.name
  virtual_network_name = azurerm_virtual_network.openvas-rg-vnet.name
  address_prefixes     = var.address_prefixes
}

resource "azurerm_virtual_machine_extension" "openvas_vm_ext" {
  name                 = "${var.environment_name}-openvas-vm-ext"
  virtual_machine_id   = azurerm_virtual_machine.openvas-vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  protected_settings = <<SETTINGS
    {
       "script": "${filebase64("${path.module}/openvas-bootstrap.sh")}"
    }
    SETTINGS

}

# resource "azurerm_virtual_network_gateway" "example" {
#   name                = "test"
#   location            = azurerm_resource_group.example.location
#   resource_group_name = azurerm_resource_group.example.name

#   type     = "Vpn"
#   vpn_type = "RouteBased"

#   active_active = false
#   enable_bgp    = false
#   sku           = "Basic"

#   ip_configuration {
#     name                          = "vnetGatewayConfig"
#     public_ip_address_id          = azurerm_public_ip.example.id
#     private_ip_address_allocation = "Dynamic"
#     subnet_id                     = azurerm_subnet.example.id
#   }

#   vpn_client_configuration {
#     address_space = ["10.4.0.0/24"]

#     root_certificate {
#       name = "DigiCert-Federated-ID-Root-CA"

#       public_cert_data = <<EOF
# MIIDuzCCAqOgAwIBAgIQCHTZWCM+IlfFIRXIvyKSrjANBgkqhkiG9w0BAQsFADBn
# MQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3
# d3cuZGlnaWNlcnQuY29tMSYwJAYDVQQDEx1EaWdpQ2VydCBGZWRlcmF0ZWQgSUQg
# Um9vdCBDQTAeFw0xMzAxMTUxMjAwMDBaFw0zMzAxMTUxMjAwMDBaMGcxCzAJBgNV
# BAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdp
# Y2VydC5jb20xJjAkBgNVBAMTHURpZ2lDZXJ0IEZlZGVyYXRlZCBJRCBSb290IENB
# MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvAEB4pcCqnNNOWE6Ur5j
# QPUH+1y1F9KdHTRSza6k5iDlXq1kGS1qAkuKtw9JsiNRrjltmFnzMZRBbX8Tlfl8
# zAhBmb6dDduDGED01kBsTkgywYPxXVTKec0WxYEEF0oMn4wSYNl0lt2eJAKHXjNf
# GTwiibdP8CUR2ghSM2sUTI8Nt1Omfc4SMHhGhYD64uJMbX98THQ/4LMGuYegou+d
# GTiahfHtjn7AboSEknwAMJHCh5RlYZZ6B1O4QbKJ+34Q0eKgnI3X6Vc9u0zf6DH8
# Dk+4zQDYRRTqTnVO3VT8jzqDlCRuNtq6YvryOWN74/dq8LQhUnXHvFyrsdMaE1X2
# DwIDAQABo2MwYTAPBgNVHRMBAf8EBTADAQH/MA4GA1UdDwEB/wQEAwIBhjAdBgNV
# HQ4EFgQUGRdkFnbGt1EWjKwbUne+5OaZvRYwHwYDVR0jBBgwFoAUGRdkFnbGt1EW
# jKwbUne+5OaZvRYwDQYJKoZIhvcNAQELBQADggEBAHcqsHkrjpESqfuVTRiptJfP
# 9JbdtWqRTmOf6uJi2c8YVqI6XlKXsD8C1dUUaaHKLUJzvKiazibVuBwMIT84AyqR
# QELn3e0BtgEymEygMU569b01ZPxoFSnNXc7qDZBDef8WfqAV/sxkTi8L9BkmFYfL
# uGLOhRJOFprPdoDIUBB+tmCl3oDcBy3vnUeOEioz8zAkprcb3GHwHAK+vHmmfgcn
# WsfMLH4JCLa/tRYL+Rw/N3ybCkDp00s0WUZ+AoDywSl0Q/ZEnNY0MsFiw6LyIdbq
# M/s/1JRtO3bDSzD9TazRVzn2oBqzSa8VgIo5C1nOnoAKJTlsClJKvIhnRlaLQqk=
# EOF

#     }

#     revoked_certificate {
#       name       = "Verizon-Global-Root-CA"
#       thumbprint = "912198EEF23DCAC40939312FEE97DD560BAE49B1"
#     }
#   }
# }
