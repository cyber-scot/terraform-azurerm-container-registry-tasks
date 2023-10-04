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
    },
  ]
}


module "acr_task_example" {
  source = "../../"

  registry_tasks = [
    {
      name   = "build_ubuntu"
      acr_id = "YOUR_ACR_ID_HERE" # Replace with your Azure Container Registry ID
      tags   = module.rg.rg_tags
      docker_step = {
        context_access_token = data.azurerm_key_vault_secret.gh_pat.value
        context_path         = "https://github.com/cyber-scot/terraform-azurerm-container-registry-tasks.git" # Assuming the Dockerfile is in the current directory
        dockerfile_path      = "examples/standard/Dockerfile"
        scheduled_run_now    = true
        arguments            = []
        secret_arguments     = []
        image_names          = ["${module.container_registry}/ubuntu:latest"]
        cache_enabled        = true
        push_enabled         = true
        target_enabled       = true
      }
      identity_type = "SystemAssigned"
    }
  ]
}
