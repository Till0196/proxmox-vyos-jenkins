resource "proxmox_virtual_environment_download_file" "cloud_image" {
  for_each = toset(var.node_names)

  content_type        = var.content_type
  datastore_id        = var.datastore_id
  file_name           = var.file_name
  node_name           = each.value
  url                 = var.url
  overwrite_unmanaged = true
}
