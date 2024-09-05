## Proxmox Vyos Jenkins
Proxmoxにterraformを用いて、vyosのLTSビルドに必要なパッケージをビルドできる仮想マシンを自動で構築します。

iso生成とcloudinitが使えるcloudimageを生成するjobもJenkinsに追加します。

利用可能なVyosのLTSバージョン
- sagitta (1.4)
- equuleus (1.3)

## terraform modules
- proxmox-cloud-image

  Proxmoxノードにclouimageをダウンロードして、ファイルを生成します。

  `node_names`はリスト型を受け付けます。
  `data.proxmox_virtual_environment_nodes`でノード情報を取得し、その情報からnodeを登録しています。

  複数のProxmoxからなるProxmoxクラスターになっている場合、全てのProxmoxクラスターにイメージが追加されます。
  特定のProxmoxノードにだけイメージをダウンロードしたい場合、`node_names = [ "pve" ]`のようにリスト型でノード名を指定することで実現できます。

  後述するproxmox-cloud-imageは単一ノードでの実行を前提としているため、仮想マシンを構築しない使用しないノードであってもcloud-imageが登録されます。

- proxmox-cloud-image-vm

  proxmox-cloud-imageでダウンロードしたcloud-imageとcloud-initを用いてUbuntu24.04をセットアップします。

  isoからcloud-imageファイルを作成するvyos-packerでqemuによるKVMを利用できるようにするため、`cpu_type = host`である必要があります。

  また、ProxmoxノードもKVMのネストが有効化されている必要があります。Proxmoxの最近のバージョンでは初期設定で有効化されています。

## scripts
- vyos-jenkins-automate-setting-wave1.sh

  [dd010101/vyos-jenkins](https://github.com/dd010101/vyos-jenkins)のstage1-4まで実行し、Jenkinsをセットアップします。

  stage2(2-jenkins.sh)に対話が必要な部分がありますが、expectと補助スクリプト(jenkins-setup-helper-scripts)を用いて自動化しています。

  adminユーザーのパスワードはterrarform内の`jenkins_admin_password`で設定した値が利用されます。

  値が指定されていない場合、`password`がパスワードとして設定されます。

  このスクリプト内の実行までは`terraform_data`リソースで実行されます。

- vyos-jenkins-automate-setting-wave2.sh

  `vyos-jenkins-automate-setting-wave1.sh`の最後に別のpidで呼び出されるスクリプトです。

  terraformの実行時間があまりにも長くなるため、このような構成になっています。

  このスクリプトがやることはdd010101/vyos-jenkinsの残りのstageを実行し、最後に`vyos-jenkins-add-build-image-job.sh`を実行します。

- vyos-jenkins-add-build-image-job.sh

  vyosのisoをビルドするJenkinsのjobを登録するスクリプトです。

  `vyos-jenkins-automate-setting-wave1.sh`内でダウンロードされた`jenkins-cli`とクレデンシャルを利用してjobを追加します。

  追加されるjobは下記の通りです。
  - build-vyos-iso-equuleus

    ビルドされたパッケージを利用してバージョンequuleus(1.3)のisoファイルを生成します。

    実行には該当バージョンの全てのパッケージが正常にビルドされている必要があります。
  - build-vyos-iso-sagitta

    ビルドされたパッケージを利用してバージョンsagitta(1.4)のisoファイルを生成します。

    実行には該当バージョンの全てのパッケージが正常にビルドされている必要があります。
  - build-vyos-cloudimage-equuleus

    `build-vyos-iso-equuleus`jobによって生成されたisoを使って、cloudinitが利用できるcloudimageをpackerで生成します。

    packerでの処理は[vyos-contrib/packer-vyos](https://github.com/vyos-contrib/packer-vyos)に依存しています。

    実行には`build-vyos-iso-equuleus`jobが正常にisoを生成されている必要があります。
  - build-vyos-cloudimage-sagitta

    `build-vyos-iso-sagitta`jobによって生成されたisoを使って、cloudinitが利用できるcloudimageを生成します。

    packerでの処理は[vyos-contrib/packer-vyos](https://github.com/vyos-contrib/packer-vyos)に依存しています。

    実行には`build-vyos-iso-sagitta`jobが正常にisoを生成されている必要があります。


## terraform-docsについて
READMEにterraform-docsを利用しています。

terraform-docsをインストールし、下記コマンドをレポジトリ直下で実行すると最新の情報に更新されます。
```bash
terraform-docs -c .terraform-docs.yml --recursive .
```
`pre-commit`がインストールされている環境の場合は、コミット時に自動で更新と作成が行われます。

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.3 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | 0.54.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | 4.0.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | 0.54.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.5 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_proxmox_cloud_image"></a> [proxmox\_cloud\_image](#module\_proxmox\_cloud\_image) | ./modules/proxmox-cloud-image | n/a |
| <a name="module_proxmox_cloud_image_vm"></a> [proxmox\_cloud\_image\_vm](#module\_proxmox\_cloud\_image\_vm) | ./modules/proxmox-cloud-image-vm | n/a |

## Resources

| Name | Type |
|------|------|
| [terraform_data.setup_vyos_jenkins](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [tls_private_key.ssh_private_key](https://registry.terraform.io/providers/hashicorp/tls/4.0.5/docs/resources/private_key) | resource |
| [proxmox_virtual_environment_nodes.nodes](https://registry.terraform.io/providers/bpg/proxmox/0.54.0/docs/data-sources/virtual_environment_nodes) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cpu"></a> [cpu](#input\_cpu) | The number of CPUs for the VM | `number` | n/a | yes |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | The disk size for the VM | `number` | n/a | yes |
| <a name="input_fqdn"></a> [fqdn](#input\_fqdn) | The FQDN of the VM | `string` | n/a | yes |
| <a name="input_memory"></a> [memory](#input\_memory) | The amount of memory for the VM | `number` | n/a | yes |
| <a name="input_pve_node_name"></a> [pve\_node\_name](#input\_pve\_node\_name) | The name of the node | `string` | n/a | yes |
| <a name="input_virtual_environment_endpoint"></a> [virtual\_environment\_endpoint](#input\_virtual\_environment\_endpoint) | The endpoint for the Proxmox Virtual Environment API (example: https://host:port) | `string` | n/a | yes |
| <a name="input_virtual_environment_password"></a> [virtual\_environment\_password](#input\_virtual\_environment\_password) | The password for the Proxmox Virtual Environment API | `string` | n/a | yes |
| <a name="input_virtual_environment_ssh"></a> [virtual\_environment\_ssh](#input\_virtual\_environment\_ssh) | The SSH configuration for the Proxmox Virtual Environment | <pre>object({<br>    node = list(object({<br>      name    = string<br>      address = string<br>    }))<br>    agent    = bool<br>    username = string<br>    password = string<br>  })</pre> | n/a | yes |
| <a name="input_virtual_environment_tls_insecure"></a> [virtual\_environment\_tls\_insecure](#input\_virtual\_environment\_tls\_insecure) | Disable TLS verification while connecting to the Proxmox VE API server. | `bool` | n/a | yes |
| <a name="input_virtual_environment_username"></a> [virtual\_environment\_username](#input\_virtual\_environment\_username) | The username and realm for the Proxmox Virtual Environment API (example: root@pam) | `string` | n/a | yes |
| <a name="input_vm_id"></a> [vm\_id](#input\_vm\_id) | The VM ID | `number` | n/a | yes |
| <a name="input_vm_name"></a> [vm\_name](#input\_vm\_name) | The name of the VM | `string` | n/a | yes |
| <a name="input_apt_mirror"></a> [apt\_mirror](#input\_apt\_mirror) | The APT mirror(Set and use with cloud-init) | `string` | `"https://ftp.udx.icscoe.jp/Linux/ubuntu"` | no |
| <a name="input_bridge_name"></a> [bridge\_name](#input\_bridge\_name) | The bridge name for the VM | `string` | `"vmbr0"` | no |
| <a name="input_cidr"></a> [cidr](#input\_cidr) | The CIDR for the VM | `string` | `""` | no |
| <a name="input_cloud_config_datastore_name"></a> [cloud\_config\_datastore\_name](#input\_cloud\_config\_datastore\_name) | The name of the datastore for the cloud config file (Content type snippets must be enabled) | `string` | `"local"` | no |
| <a name="input_cpu_type"></a> [cpu\_type](#input\_cpu\_type) | The CPU type for the VM (packer qemu only works host type) | `string` | `"host"` | no |
| <a name="input_dhcp"></a> [dhcp](#input\_dhcp) | Use DHCP for the IP address | `bool` | `false` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | The DNS servers | `list(string)` | <pre>[<br>  "1.1.1.1",<br>  "8.8.8.8"<br>]</pre> | no |
| <a name="input_gateway"></a> [gateway](#input\_gateway) | The gateway address for the VM | `string` | `""` | no |
| <a name="input_ip"></a> [ip](#input\_ip) | The IP address for the VM | `string` | `""` | no |
| <a name="input_jenkins_admin_password"></a> [jenkins\_admin\_password](#input\_jenkins\_admin\_password) | The Jenkins admin password | `string` | `"password"` | no |
| <a name="input_locale"></a> [locale](#input\_locale) | The locale(Set and use with cloud-init) | `string` | `"en_US.UTF-8"` | no |
| <a name="input_on_boot"></a> [on\_boot](#input\_on\_boot) | Start the VM on PVE node boot | `bool` | `true` | no |
| <a name="input_os_datastore_lvm_name"></a> [os\_datastore\_lvm\_name](#input\_os\_datastore\_lvm\_name) | The OS datastore LVM name | `string` | `"local-lvm"` | no |
| <a name="input_ssh_pwauth"></a> [ssh\_pwauth](#input\_ssh\_pwauth) | Enable password authentication | `bool` | `false` | no |
| <a name="input_timezone"></a> [timezone](#input\_timezone) | The timezone(Set and use with cloud-init) | `string` | `"Asia/Tokyo"` | no |
| <a name="input_vm_tags"></a> [vm\_tags](#input\_vm\_tags) | The tags for the VM | `list(string)` | <pre>[<br>  "terraform-managed"<br>]</pre> | no |
| <a name="input_vm_user"></a> [vm\_user](#input\_vm\_user) | The VM user | `string` | `"ubuntu"` | no |
| <a name="input_vm_user_password"></a> [vm\_user\_password](#input\_vm\_user\_password) | The VM user password | `string` | `"password"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_proxmox_cloud_image"></a> [proxmox\_cloud\_image](#output\_proxmox\_cloud\_image) | downloaded cloud image file IDs and node names |
| <a name="output_proxmox_cloud_image_vm"></a> [proxmox\_cloud\_image\_vm](#output\_proxmox\_cloud\_image\_vm) | created cloud image VM |
<!-- END_TF_DOCS -->
