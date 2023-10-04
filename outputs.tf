output "acr_task_enabled_statuses" {
  description = "The enabled statuses of the Azure Container Registry tasks."
  value       = [for task in azurerm_container_registry_task.acr_task : task.enabled]
}

output "acr_task_ids" {
  description = "The IDs of the Azure Container Registry tasks."
  value       = [for task in azurerm_container_registry_task.acr_task : task.id]
}

output "acr_task_names" {
  description = "The names of the Azure Container Registry tasks."
  value       = [for task in azurerm_container_registry_task.acr_task : task.name]
}

output "acr_task_principal_ids" {
  description = "The Principal IDs associated with the Managed Service Identities of the Azure Container Registry tasks."
  value       = [for task in azurerm_container_registry_task.acr_task : task.identity.principal_id]
}

output "acr_task_tenant_ids" {
  description = "The Tenant IDs associated with the Managed Service Identities of the Azure Container Registry tasks."
  value       = [for task in azurerm_container_registry_task.acr_task : task.identity.tenant_id]
}

output "schedule_run_now_ids" {
  description = "The IDs of the Azure Container Registry task schedule run now."
  value       = [for task in azurerm_container_registry_task_schedule_run_now.schedule_run_now : task.id]
}
