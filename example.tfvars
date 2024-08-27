# Proxmox VE
########################################################################
# Proxmox VE API details and VM hosting configuration
# API token guide: https://registry.terraform.io/providers/bpg/proxmox/2.9.14/docs

virtual_environment_endpoint     = "https://192.168.0.10:8006"
virtual_environment_username     = "root@pam"
virtual_environment_password     = "password"
virtual_environment_tls_insecure = true

virtual_environment_ssh = {
  node = [{
    name    = "pve"
    address = "192.168.0.10"
  }]
  agent    = true
  username = "root"
  password = "password"
}

# VM specifications
########################################################################

pve_node_name = "pve"

vm_name = "vyos-builder"
vm_id = 200
vm_tags = [ "terraform-managed", "vyos" ]

on_boot = false

cpu = 4
cpu_type = "host"
memory = 8096

# Network configuration
bridge_name = "vmbr0"

dhcp = true
ip = ""
cidr = ""
gateway = ""
dns_servers = [ "1.1.1.1" ]

# Disk configuration
os_datastore_lvm_name = "local-lvm"
disk_size = 100

# cloud-init configuration
cloud_config_datastore_name = "local"
vm_user = "ubuntu"
vm_user_password = "password"
fqdn = "vyos-builder.local"

timezone = "Asia/Tokyo"
locale = "ja_JP.UTF-8"
apt_mirror = "https://ftp.udx.icscoe.jp/Linux/ubuntu"
ssh_pwauth = true

# jenkins
jenkins_admin_password = "password"
