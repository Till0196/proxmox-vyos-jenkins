output "file_ids" {
  value = {
    for node_name in var.node_names : node_name => {
      node_name = proxmox_virtual_environment_download_file.cloud_image[node_name].node_name,
      id        = proxmox_virtual_environment_download_file.cloud_image[node_name].id
    }
  }
  description = "file IDs of the cloud image"
}
