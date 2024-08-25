resource "proxmox_virtual_environment_vm" "cloud_image_vm" {
  vm_id     = var.vm_id
  name      = var.vm_name
  tags      = var.vm_tags
  node_name = var.pve_node_name
  
  on_boot = var.on_boot

  machine   = "q35"
  bios      = "ovmf"

  cpu {
    cores = var.cpu
    type  = var.cpu_type
  }

  memory {
    dedicated = var.memory
  }

  initialization {
    interface = "scsi1"

    dns {
      servers = var.dns_servers
    }

    ip_config {
      ipv4 {
        address = "${var.dhcp ? "dhcp" : "${var.ip}/${var.cidr}"}"
        gateway = "${var.dhcp ? null : "${var.gateway}"}"
      }
    }

    datastore_id      = var.os_datastore_lvm_name
    user_data_file_id = proxmox_virtual_environment_file.cloud_config.id
  }

  agent {
    enabled = true
  }

  operating_system {
    type = "l26" # Linux Kernel 2.6 - 6.X.
  }

  scsi_hardware = "virtio-scsi-pci"

  network_device {
    bridge = var.bridge_name
    model  = "virtio"
  }

  efi_disk {
    datastore_id = var.os_datastore_lvm_name
    file_format  = "raw"
    type         = "4m"
  }

  disk {
    datastore_id = var.os_datastore_lvm_name
    file_id      = var.cloud_image_file_id
    file_format = "raw"
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = var.disk_size
  }

  lifecycle {
    ignore_changes = all
  }
}

resource "proxmox_virtual_environment_file" "cloud_config" {
  content_type = "snippets"
  datastore_id = var.cloud_config_datastore_name
  node_name    = var.pve_node_name

  source_raw {
    data      = templatefile("${path.module}/cloud-init/cloud-init.yaml.tpl",
      {
        hostname       = var.vm_name,
        fqdn           = var.fqdn,
        timezone       = var.timezone,
        locale         = var.locale,
        username       = var.vm_user,
        password       = bcrypt(var.vm_user_password),
        apt_mirror     = var.apt_mirror,
        ssh_public_key = tolist([trimspace(var.ssh_public_key_content)])
        ssh_pwauth     = var.ssh_pwauth
      }
    )
    file_name = "cloud-init-${var.vm_name}.yaml"
  }

  lifecycle {
    ignore_changes = all
  }
}
