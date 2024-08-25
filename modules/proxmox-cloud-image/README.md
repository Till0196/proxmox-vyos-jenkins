<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.3 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | 0.54.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | 0.54.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [proxmox_virtual_environment_download_file.cloud_image](https://registry.terraform.io/providers/bpg/proxmox/0.54.0/docs/resources/virtual_environment_download_file) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_file_name"></a> [file\_name](#input\_file\_name) | File name of the cloud image | `string` | n/a | yes |
| <a name="input_url"></a> [url](#input\_url) | URL of the cloud image | `string` | n/a | yes |
| <a name="input_content_type"></a> [content\_type](#input\_content\_type) | Content type of the cloud image | `string` | `"iso"` | no |
| <a name="input_datastore_id"></a> [datastore\_id](#input\_datastore\_id) | Datastore ID for the cloud image | `string` | `"local"` | no |
| <a name="input_node_names"></a> [node\_names](#input\_node\_names) | Node name list for the cloud image | `list(string)` | <pre>[<br>  "pve"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_file_ids"></a> [file\_ids](#output\_file\_ids) | file IDs of the cloud image |
<!-- END_TF_DOCS -->
