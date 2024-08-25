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
| [proxmox_virtual_environment_file.cloud_config](https://registry.terraform.io/providers/bpg/proxmox/0.54.0/docs/resources/virtual_environment_file) | resource |
| [proxmox_virtual_environment_vm.cloud_image_vm](https://registry.terraform.io/providers/bpg/proxmox/0.54.0/docs/resources/virtual_environment_vm) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_image_file_id"></a> [cloud\_image\_file\_id](#input\_cloud\_image\_file\_id) | The cloud image file ID | `string` | n/a | yes |
| <a name="input_apt_mirror"></a> [apt\_mirror](#input\_apt\_mirror) | The APT mirror(Set and use with cloud-init) | `string` | `"https://ftp.udx.icscoe.jp/Linux/ubuntu"` | no |
| <a name="input_bridge_name"></a> [bridge\_name](#input\_bridge\_name) | The bridge name | `string` | `"vmbr0"` | no |
| <a name="input_cidr"></a> [cidr](#input\_cidr) | The CIDR for the VM | `string` | `""` | no |
| <a name="input_cloud_config_datastore_name"></a> [cloud\_config\_datastore\_name](#input\_cloud\_config\_datastore\_name) | The name of the datastore for the cloud config file (Content type snippets must be enabled) | `string` | `"local"` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | The number of CPUs for the VM | `number` | `2` | no |
| <a name="input_cpu_type"></a> [cpu\_type](#input\_cpu\_type) | The CPU type for the VM | `string` | `"qemu64"` | no |
| <a name="input_dhcp"></a> [dhcp](#input\_dhcp) | Use DHCP for the IP address | `bool` | `false` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | The size of the disk | `number` | `8` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | The DNS servers | `list(string)` | <pre>[<br>  "1.1.1.1",<br>  "8.8.8.8"<br>]</pre> | no |
| <a name="input_fqdn"></a> [fqdn](#input\_fqdn) | The FQDN of the VM | `string` | `"vyos-builder.local"` | no |
| <a name="input_gateway"></a> [gateway](#input\_gateway) | The gateway address for the VM | `string` | `""` | no |
| <a name="input_ip"></a> [ip](#input\_ip) | The IP address for the VM | `string` | `""` | no |
| <a name="input_locale"></a> [locale](#input\_locale) | The locale(Set and use with cloud-init) | `string` | `"en_US.UTF-8"` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | The amount of memory for the VM | `number` | `2048` | no |
| <a name="input_on_boot"></a> [on\_boot](#input\_on\_boot) | Start the VM on PVE node boot | `bool` | `true` | no |
| <a name="input_os_datastore_lvm_name"></a> [os\_datastore\_lvm\_name](#input\_os\_datastore\_lvm\_name) | The name of the LVM datastore for the OS | `string` | `"local-lvm"` | no |
| <a name="input_pve_node_name"></a> [pve\_node\_name](#input\_pve\_node\_name) | The name of the PVE node create VM in | `string` | `"pve"` | no |
| <a name="input_ssh_public_key_content"></a> [ssh\_public\_key\_content](#input\_ssh\_public\_key\_content) | The public key | `string` | `""` | no |
| <a name="input_ssh_pwauth"></a> [ssh\_pwauth](#input\_ssh\_pwauth) | Enable password authentication | `bool` | `false` | no |
| <a name="input_timezone"></a> [timezone](#input\_timezone) | The timezone(Set and use with cloud-init) | `string` | `"Asia/Tokyo"` | no |
| <a name="input_vm_id"></a> [vm\_id](#input\_vm\_id) | The VM ID | `number` | `8000` | no |
| <a name="input_vm_name"></a> [vm\_name](#input\_vm\_name) | The name of the VM | `string` | `"vyos-builder"` | no |
| <a name="input_vm_tags"></a> [vm\_tags](#input\_vm\_tags) | The tags for the VM | `list(string)` | <pre>[<br>  "terraform-managed"<br>]</pre> | no |
| <a name="input_vm_user"></a> [vm\_user](#input\_vm\_user) | The default user for VM | `string` | `"ubuntu"` | no |
| <a name="input_vm_user_password"></a> [vm\_user\_password](#input\_vm\_user\_password) | The password for logging in | `string` | `"password"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloud_image_vm"></a> [cloud\_image\_vm](#output\_cloud\_image\_vm) | values of the cloud image VM |
<!-- END_TF_DOCS -->
