# Terraform-azurerm-openvas

Azure Terrafrom module for spinning up an instance running openvas

Depends on - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs

Uses https://github.com/admirito's great OpenVas/GVM dockers - https://github.com/admirito/gvm-containers

Wait at least 10 minutes for vulnerability database to sync before use, login at http://<hostname>:8080 with admin/admin

Sponserd by DevSecOps at https://www.nox90.com

