terraform {
  required_version = ">= 1.3.3"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.54.0"
    }
  }
}
