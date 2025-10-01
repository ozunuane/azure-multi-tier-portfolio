// This alert will be triggered when Memory Utilization exceeds 80% for longer than 5 minutes
resource "azurerm_monitor_metric_alert" "psql_memory_usage" {
  name                = "${var.name}-memory_usage"
  resource_group_name = var.resource_group_name
  scopes              = [var.azurerm_postgresql_flexible_server_id]
  description         = "Action will be triggered when Memory utilization exceeds 80% for longer than 5 minutes"
  frequency           = "PT5M"
  window_size         = "PT5M"
  auto_mitigate       = true
  enabled             = true
  severity            = 1
  criteria {
    metric_namespace = "Microsoft.DBforPostgreSQL/flexibleServers"
    metric_name      = "memory_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }
  action {
    action_group_id = var.action_group_id
  }
  tags = var.tags
  # depends_on = [
  #   azurerm_resource_group.rg,
  #   azurerm_postgresql_flexible_server.psql,    
  # ]
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}



// This alert will be triggered when CPU Utilization exceeds 80% for longer than 5 minutes
resource "azurerm_monitor_metric_alert" "psql_cpu_usage" {
  name                = "${var.name}-cpu_usage"
  resource_group_name = var.resource_group_name
  scopes              = [var.azurerm_postgresql_flexible_server_id]
  description         = "Action will be triggered when CPU utilization exceeds 80% for longer than 5 minutes"
  frequency           = "PT5M"
  window_size         = "PT5M"
  severity            = var.alert_severity
  criteria {
    metric_namespace = "Microsoft.DBforPostgreSQL/flexibleServers"
    metric_name      = "cpu_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }
  action {
    action_group_id = var.action_group_id
  }
  tags = var.tags
  # depends_on = [
  #   azurerm_resource_group.rg,
  #   azurerm_postgresql_flexible_server.psql,    
  # ]
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}
