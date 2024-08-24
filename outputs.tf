output "cloud_image" {
  value = module.proxmox_cloud_image.file_ids
}

output "cloud_image_vm" {
  value = module.proxmox_cloud_image_vm.cloud_image_vm
}
