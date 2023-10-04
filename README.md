
```hcl
resource "azurerm_container_registry_task" "acr_task" {
  for_each              = { for task in var.registry_tasks : task.name => task }
  name                  = each.value.name
  container_registry_id = each.value.acr_id
  agent_pool_name       = try(each.value.agent_pool_name, null)
  enabled               = try(each.value.enabled, true)
  log_template          = try(each.value.log_template, null)
  tags                  = each.value.tags
  is_system_task        = try(each.value.is_system_task, null)


  dynamic "agent_setting" {
    for_each = each.value.agent_setting != null ? [each.value.agent_setting] : []
    content {
      cpu = agent_setting.value.cpu
    }
  }

  dynamic "base_image_trigger" {
    for_each = each.value.base_image_trigger != null ? [each.value.base_image_trigger] : []
    content {
      name                        = base_image_trigger.value.name
      type                        = base_image_trigger.value.type
      enabled                     = base_image_trigger.value.enabled
      update_trigger_endpoint     = base_image_trigger.value.update_trigger_endpoint
      update_trigger_payload_type = base_image_trigger.value.update_trigger_payload_type
    }
  }

  dynamic "docker_step" {
    for_each = each.value.docker_step != null ? [each.value.docker_step] : []
    content {
      context_access_token = docker_step.value.context_access_token
      context_path         = docker_step.value.context_path
      dockerfile_path      = docker_step.value.dockerfile_path
      arguments            = docker_step.value.arguements
      secret_arguments     = docker_step.value.secret_arguments
      image_names          = docker_step.value.image_names
      cache_enabled        = docker_step.value.cache_enabled
      push_enabled         = docker_step.value.push_enabled
      target               = docker_step.value.target_enabled
    }
  }

  dynamic "encoded_step" {
    for_each = each.value.encoded_step != null ? [each.value.encoded_step] : []
    content {
      task_content         = encoded_step.value.task_content
      context_access_token = encoded_step.value.context_access_token
      context_path         = encoded_step.value.context_path
      secret_values        = encoded_step.value.secret_values
      value_content        = encoded_step.value.value_content
      values               = encoded_step.value.values
    }
  }

  dynamic "file_step" {
    for_each = each.value.file_step != null ? [each.value.file_step] : []
    content {
      task_file_path       = file_step.value.task_file_path
      context_access_token = file_step.value.context_access_token
      context_path         = file_step.value.context_path
      secret_values        = file_step.value.secret_values
      value_file_path      = file_step.value.value_file_path
      values               = file_step.value.values
    }
  }

  dynamic "platform" {
    for_each = each.value.platform != null ? [each.value.platform] : []
    content {
      os           = platform.value.os
      architecture = platform.value.architecture
      variant      = platform.value.variant
    }
  }

  dynamic "registry_credential" {
    for_each = each.value.registry_credential != null ? [each.value.registry_credential] : []
    content {
      dynamic "source" {
        for_each = registry_credential.value.source != null ? [registry_credential.value.source] : []
        content {
          login_mode = source.value.login_mode
        }
      }

      dynamic "custom" {
        for_each = registry_credential.value.custom != null ? [registry_credential.value.custom] : []
        content {
          login_server = custom.value.login_server
          identity     = custom.value.identity
          username     = custom.value.username
          password     = custom.value.password
        }
      }
    }
  }

  dynamic "source_trigger" {
    for_each = each.value.source_trigger != null ? [each.value.source_trigger] : []
    content {
      name           = source_trigger.value.name
      events         = source_trigger.value.events
      repository_url = source_trigger.value.repository_url
      source_type    = source_trigger.value.source_type
      branch         = source_trigger.value.branch
      enabled        = source_trigger.value.enabled

      dynamic "authentication" {
        for_each = source_trigger.value.authentication != null ? [source_trigger.value.authentication] : []
        content {
          token             = authentication.value.token
          token_type        = authentication.value.token_type
          expire_in_seconds = authentication.value.expire_in_seconds
          refresh_token     = authentication.value.refresh_token
          scope             = authentication.value.scope
        }
      }
    }
  }

  dynamic "timer_trigger" {
    for_each = each.value.timer_trigger != null ? [each.value.timer_trigger] : []
    content {
      name     = timer_trigger.value.name
      schedule = timer_trigger.value.schedule
      enabled  = timer_trigger.value.enabled
    }
  }

  dynamic "identity" {
    for_each = try(length(each.value.identity_ids) > 0 && each.value.identity_type == "SystemAssigned", false) ? [each.value.identity_type] : []
    content {
      type = each.value.identity_type
    }
  }

  dynamic "identity" {
    for_each = try(length(each.value.identity_ids), 0) > 0 || each.value.identity_type == "SystemAssigned, UserAssigned" ? [each.value.identity_type] : []
    content {
      type         = each.value.identity_type
      identity_ids = try(each.value.identity_ids, [])
    }
  }


  dynamic "identity" {
    for_each = try(length(each.value.identity_ids), 0) > 0 || each.value.identity_type == "SystemAssigned, UserAssigned" ? [each.value.identity_type] : []
    content {
      type         = each.value.identity_type
      identity_ids = length(try(each.value.identity_ids, [])) > 0 ? each.value.identity_ids : []
    }
  }
}

resource "azurerm_container_registry_task_schedule_run_now" "schedule_run_now" {
  for_each                   = { for task in var.registry_tasks : task.name => task if each.value.schedule_run_now == true }
  container_registry_task_id = azurerm_container_registry_task.acr_task[each.key].id
}
```
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_container_registry_task.acr_task](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry_task) | resource |
| [azurerm_container_registry_task_schedule_run_now.schedule_run_now](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry_task_schedule_run_now) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_registry_tasks"></a> [registry\_tasks](#input\_registry\_tasks) | List of registry tasks. | <pre>list(object({<br>    name            = string<br>    acr_id          = string<br>    agent_pool_name = optional(string)<br>    enabled         = optional(bool)<br>    log_template    = optional(string)<br>    tags            = map(string)<br>    is_system_task  = optional(bool)<br>    agent_setting = optional(object({<br>      cpu = number<br>    }))<br>    base_image_trigger = optional(object({<br>      name                        = string<br>      type                        = string<br>      enabled                     = bool<br>      update_trigger_endpoint     = string<br>      update_trigger_payload_type = string<br>    }))<br>    docker_step = optional(object({<br>      context_access_token = string<br>      context_path         = string<br>      dockerfile_path      = string<br>      arguments            = list(string)<br>      secret_arguments     = list(string)<br>      image_names          = list(string)<br>      cache_enabled        = bool<br>      push_enabled         = bool<br>      target_enabled       = bool<br>    }))<br>    encoded_step = optional(object({<br>      task_content         = string<br>      context_access_token = string<br>      context_path         = string<br>      secret_values        = list(string)<br>      value_content        = string<br>      values               = list(string)<br>    }))<br>    file_step = optional(object({<br>      task_file_path       = string<br>      context_access_token = string<br>      context_path         = string<br>      secret_values        = list(string)<br>      value_file_path      = string<br>      values               = list(string)<br>    }))<br>    platform = optional(object({<br>      os           = string<br>      architecture = string<br>      variant      = optional(string)<br>    }))<br>    registry_credential = optional(object({<br>      source = optional(object({<br>        login_mode = string<br>      }))<br>      custom = optional(object({<br>        login_server = string<br>        identity     = string<br>        username     = string<br>        password     = string<br>      }))<br>    }))<br>    source_trigger = optional(object({<br>      name           = string<br>      events         = list(string)<br>      repository_url = string<br>      source_type    = string<br>      branch         = string<br>      enabled        = bool<br>      authentication = optional(object({<br>        token             = string<br>        token_type        = string<br>        expire_in_seconds = number<br>        refresh_token     = string<br>        scope             = string<br>      }))<br>    }))<br>    timer_trigger = optional(object({<br>      name     = string<br>      schedule = string<br>      enabled  = bool<br>    }))<br>    identity_type    = string<br>    identity_ids     = optional(list(string))<br>    schedule_run_now = optional(bool)<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_acr_task_enabled_statuses"></a> [acr\_task\_enabled\_statuses](#output\_acr\_task\_enabled\_statuses) | The enabled statuses of the Azure Container Registry tasks. |
| <a name="output_acr_task_ids"></a> [acr\_task\_ids](#output\_acr\_task\_ids) | The IDs of the Azure Container Registry tasks. |
| <a name="output_acr_task_names"></a> [acr\_task\_names](#output\_acr\_task\_names) | The names of the Azure Container Registry tasks. |
| <a name="output_acr_task_principal_ids"></a> [acr\_task\_principal\_ids](#output\_acr\_task\_principal\_ids) | The Principal IDs associated with the Managed Service Identities of the Azure Container Registry tasks. |
| <a name="output_acr_task_tenant_ids"></a> [acr\_task\_tenant\_ids](#output\_acr\_task\_tenant\_ids) | The Tenant IDs associated with the Managed Service Identities of the Azure Container Registry tasks. |
| <a name="output_schedule_run_now_ids"></a> [schedule\_run\_now\_ids](#output\_schedule\_run\_now\_ids) | The IDs of the Azure Container Registry task schedule run now. |
