data "proxmox_virtual_environment_nodes" "nodes" {}

module "proxmox_cloud_image" {
  source = "./modules/proxmox-cloud-image"

  node_names = data.proxmox_virtual_environment_nodes.nodes.names

  file_name = "noble-server-cloudimg-amd64.img"
  url       = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
}

resource "tls_private_key" "ssh_private_key" {
  algorithm = "ED25519"
}

module "proxmox_cloud_image_vm" {
  source = "./modules/proxmox-cloud-image-vm"

  pve_node_name = var.pve_node_name

  vm_name = var.vm_name
  vm_id   = var.vm_id
  vm_tags = var.vm_tags

  on_boot = var.on_boot

  cpu      = var.cpu
  cpu_type = var.cpu_type
  memory   = var.memory

  os_datastore_lvm_name = var.os_datastore_lvm_name
  disk_size             = var.disk_size

  bridge_name = var.bridge_name
  dhcp        = var.dhcp
  ip          = var.ip
  cidr        = var.cidr
  gateway     = var.gateway
  dns_servers = var.dns_servers

  cloud_image_file_id         = module.proxmox_cloud_image.file_ids[var.pve_node_name].id
  cloud_config_datastore_name = var.cloud_config_datastore_name
  vm_user                     = var.vm_user
  vm_user_password            = var.vm_user_password
  fqdn                        = var.fqdn

  timezone   = var.timezone
  locale     = var.locale
  apt_mirror = var.apt_mirror
  ssh_pwauth = var.ssh_pwauth

  ssh_public_key_content = tls_private_key.ssh_private_key.public_key_openssh
}

resource "terraform_data" "setup_vyos_jenkins" {
  connection {
    type        = "ssh"
    user        = var.vm_user
    private_key = tls_private_key.ssh_private_key.private_key_pem
    host        = module.proxmox_cloud_image_vm.cloud_image_vm.ip
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /tmp/scripts/",
      "mkdir -p /tmp/jenkinsfiles/"
    ]
  }

  provisioner "file" {
    source      = "${path.cwd}/scripts/"
    destination = "/tmp/scripts/"
  }

  provisioner "file" {
    source      = "${path.cwd}/jenkinsfiles/"
    destination = "/tmp/jenkinsfiles/"
  }

  provisioner "file" {
    content     = var.jenkins_admin_password
    destination = "/tmp/jenkins-admin-password.txt"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/scripts/vyos-jenkins-automate-setting-wave1.sh",
      "sudo bash /tmp/scripts/vyos-jenkins-automate-setting-wave1.sh"
    ]
  }
}
