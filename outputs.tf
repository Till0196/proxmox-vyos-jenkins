output "proxmox_cloud_image" {
  value       = module.proxmox_cloud_image.file_ids
  description = "downloaded cloud image file IDs and node names"
}

output "proxmox_cloud_image_vm" {
  value       = module.proxmox_cloud_image_vm.cloud_image_vm
  description = "created cloud image VM"
}
