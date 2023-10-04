variable "registry_tasks" {
  description = "List of registry tasks."
  type = list(object({
    name            = string
    acr_id          = string
    agent_pool_name = optional(string)
    enabled         = optional(bool)
    log_template    = optional(string)
    tags            = map(string)
    is_system_task  = optional(bool)
    agent_setting = optional(object({
      cpu = number
    }))
    base_image_trigger = optional(object({
      name                        = string
      type                        = string
      enabled                     = bool
      update_trigger_endpoint     = string
      update_trigger_payload_type = string
    }))
    docker_step = optional(object({
      context_access_token = string
      context_path         = string
      dockerfile_path      = string
      arguments            = optional(map(string), {})
      secret_arguments     = optional(map(string), {})
      image_names          = list(string)
      cache_enabled        = optional(bool, true)
      push_enabled         = optional(bool, true)
      enabled              = optional(bool, true)
      target               = optional(string)
    }))
    encoded_step = optional(object({
      task_content         = string
      context_access_token = string
      context_path         = string
      secret_values        = list(string)
      value_content        = string
      values               = list(string)
    }))
    file_step = optional(object({
      task_file_path       = string
      context_access_token = string
      context_path         = string
      secret_values        = list(string)
      value_file_path      = string
      values               = list(string)
    }))
    platform = optional(object({
      os           = string
      architecture = optional(string)
      variant      = optional(string)
    }))
    registry_credential = optional(object({
      source = optional(object({
        login_mode = string
      }))
      custom = optional(object({
        login_server = string
        identity     = string
        username     = string
        password     = string
      }))
    }))
    source_trigger = optional(object({
      name           = string
      events         = list(string)
      repository_url = string
      source_type    = string
      branch         = string
      enabled        = bool
      authentication = optional(object({
        token             = string
        token_type        = string
        expire_in_seconds = number
        refresh_token     = string
        scope             = string
      }))
    }))
    timer_trigger = optional(object({
      name     = string
      schedule = string
      enabled  = bool
    }))
    identity_type    = string
    identity_ids     = optional(list(string))
    schedule_run_now = optional(bool, true)
  }))
  default = []
}
