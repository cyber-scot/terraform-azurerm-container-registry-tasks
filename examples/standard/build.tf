module "rg" {
  source = "cyber-scot/rg/azurerm"

  name     = "rg-${var.short}-${var.loc}-${var.env}-01"
  location = local.location
  tags     = local.tags
}

module "network" {
  source = "cyber-scot/network/azurerm"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location
  tags     = module.rg.rg_tags

  vnet_name          = "vnet-${var.short}-${var.loc}-${var.env}-01"
  vnet_location      = module.rg.rg_location
  vnet_address_space = ["10.0.0.0/16"]

  subnets = {
    "sn1-${module.network.vnet_name}" = {
      prefix            = "10.0.0.0/24",
      service_endpoints = ["Microsoft.Storage"]
    }
  }
}

module "container_registry" {
  source = "cyber-scot/container-registry/azurerm"

  registries = [
    {
      name                  = "acr${var.short}${var.loc}${var.env}01"
      rg_name               = module.rg.rg_name
      location              = module.rg.rg_location
      tags                  = module.rg.rg_tags
      admin_enabled         = true
      sku                   = "Basic"
      export_policy_enabled = true
    }
  ]
}

module "registry_task" {
  source = "cyber-scot/container-registry-tasks/azurerm"

  registry_tasks = [
    {
      name   = "build_ubuntu_nginx"
      acr_id = module.container_registry.registry_ids[0] # Replace with your Azure Container Registry ID
      tags   = module.rg.rg_tags
      platform = {
        os = "Linux"
      }
      docker_step = {
        context_access_token = data.azurerm_key_vault_secret.gh_pat.value
        context_path         = "https://github.com/cyber-scot/terraform-azurerm-container-registry-tasks.git"
        dockerfile_path      = "examples/standard/Dockerfile"
        schedule_run_now     = true
        image_names          = ["${module.container_registry.registry_login_servers[0]}/ubuntu-nginx:latest"]
      }
      identity_type = "SystemAssigned"
    },
  ]
}
