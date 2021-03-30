variable location {}
variable vm_ip_address {}
variable environment_name {}
variable machine_size {
    default = "Standard_B2ms"
}
variable admin_username {
    default = "azureuser"
}
variable ssh_key {

}

variable address_space {
    type = list
}
variable address_prefixes {
    type = list
}

