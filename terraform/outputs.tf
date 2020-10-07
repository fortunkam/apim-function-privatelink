output "spoke_resource_group" {
    value = local.resource_group_spoke_name
}

output "function_name" {
    value = local.function
}

output "vnet_spoke_name" {
    value = local.vnet_spoke_name
}

output "function_subnet" {
    value = local.function_subnet
}

output "bastion_password" {
    value = random_password.bastion_password.result
}