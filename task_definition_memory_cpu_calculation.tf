locals {
  reverse_proxy_cpu_allocation                  = floor(var.task_definition_memory_cpu_configuration.cpu * try(var.side_car_resource_allocation_configuration.reverse_proxy.cpu, 0.125))
  firelense_log_agent_cpu_allocation            = floor(var.task_definition_memory_cpu_configuration.cpu * try(var.side_car_resource_allocation_configuration.firelense_log_agent.cpu, 0.125))
  new_relic_infrastructure_agent_cpu_allocation = floor(var.task_definition_memory_cpu_configuration.cpu * try(var.side_car_resource_allocation_configuration.new_relic_infrastructure_agent.cpu, 0.125))
  calculated_application_cpu_allocation         = floor(var.task_definition_memory_cpu_configuration.cpu - sum([for side_car in local.side_cars : side_car.cpu]))

  reverse_proxy_memory_allocation                  = floor(var.task_definition_memory_cpu_configuration.memory * try(var.side_car_resource_allocation_configuration.reverse_proxy.memory, 0.0625))
  firelense_log_agent_memory_allocation            = floor(var.task_definition_memory_cpu_configuration.memory * try(var.side_car_resource_allocation_configuration.firelense_log_agent.memory, 0.0625))
  new_relic_infrastructure_agent_memory_allocation = floor(var.task_definition_memory_cpu_configuration.memory * try(var.side_car_resource_allocation_configuration.new_relic_infrastructure_agent.memory, 0.125))
  calculated_application_memory_allocation         = floor(var.task_definition_memory_cpu_configuration.memory - sum([for side_car in local.side_cars : side_car.memory]))
}
