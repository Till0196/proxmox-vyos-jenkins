terraform {
  required_version = ">= 1.3.3"

  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.54.0"
    }
  }
}
