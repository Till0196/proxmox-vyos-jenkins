output "cloud_image_vm" {
    value = { 
        name = proxmox_virtual_environment_vm.cloud_image_vm.name,
        ip = element(element(
                proxmox_virtual_environment_vm.cloud_image_vm.ipv4_addresses,
                index(proxmox_virtual_environment_vm.cloud_image_vm.network_interface_names, "eth0")
            ),0),
        memory = proxmox_virtual_environment_vm.cloud_image_vm.memory[0].dedicated,
        cpu = proxmox_virtual_environment_vm.cloud_image_vm.cpu[0].cores
    }
}
