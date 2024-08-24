
variable "virtual_environment_endpoint" {
  type        = string
  description = "The endpoint for the Proxmox Virtual Environment API (example: https://host:port)"
}

variable "virtual_environment_password" {
  type        = string
  description = "The password for the Proxmox Virtual Environment API"
}

variable "virtual_environment_username" {
  type        = string
  description = "The username and realm for the Proxmox Virtual Environment API (example: root@pam)"
}

variable "virtual_environment_tls_insecure" {
  type        = bool
  description = "Disable TLS verification while connecting to the Proxmox VE API server."
}

variable "virtual_environment_ssh" {
  type = object({
    node = list(object({
      name    = string
      address = string
    }))
    agent    = bool
    username = string
    password = string
  })
  description = "The SSH configuration for the Proxmox Virtual Environment"
}

variable "pve_node_name" {
  type        = string
  description = "The name of the node"
}

variable "on_boot" {
  type        = bool
  description = "Start the VM on PVE node boot"
  default     = true
}

variable "vm_name" {
  type        = string
  description = "The name of the VM"
}

variable "fqdn" {
  type        = string
  description = "The FQDN of the VM"
}

variable "vm_id" {
  type        = number
  description = "The VM ID"
}

variable "vm_tags" {
  type        = list(string)
  description = "The tags for the VM"
  default     = ["terraform-managed"]
}

variable "cpu" {
  type        = number
  description = "The number of CPUs for the VM"
}

variable "cpu_type" {
  type        = string
  description = "The CPU type for the VM (packer qemu only works host type)"
  default     = "host"
}

variable "memory" {
  type        = number
  description = "The amount of memory for the VM"
}

variable "bridge_name" {
  type        = string
  description = "The bridge name for the VM"
  default = "vmbr0"
}

variable "dhcp" {
  type        = bool
  description = "Use DHCP for the IP address"
  default     = false
}

variable "ip" {
  type        = string
  description = "The IP address for the VM"
  default   = ""
}

variable "cidr" {
  type        = string
  description = "The CIDR for the VM"
  default    = ""
}

variable "gateway" {
  type        = string
  description = "The gateway address for the VM"
  default     = ""
}

variable "os_datastore_lvm_name" {
  type        = string
  description = "The OS datastore LVM name"
  default    = "local-lvm"
}

variable "disk_size" {
  type        = number
  description = "The disk size for the VM"
}

variable "cloud_config_datastore_name" {
  type        = string
  description = "The name of the datastore for the cloud config file (Content type snippets must be enabled)"
  default     = "local"
}

variable "timezone" {
  type        = string
  description = "The timezone(Set and use with cloud-init)"
  default     = "Asia/Tokyo"
}

variable "locale" {
  type        = string
  description = "The locale(Set and use with cloud-init)"
  default     = "en_US.UTF-8"
}

variable "apt_mirror" {
  type        = string
  description = "The APT mirror(Set and use with cloud-init)"
  default     = "https://ftp.udx.icscoe.jp/Linux/ubuntu"
}

variable "vm_user" {
  type        = string
  description = "The VM user"
  default = "ubuntu"
}

variable "vm_user_password" {
  type        = string
  description = "The VM user password"
  default     = "password"
  sensitive   = true
}

variable "ssh_pwauth" {
  type        = bool
  description = "Enable password authentication"
  default     = false
}

variable "dns_servers" {
  type        = list(string)
  description = "The DNS servers"
  default     = ["1.1.1.1", "8.8.8.8"]
}

variable "jenkins_admin_password" {
  type = string
  description = "The Jenkins admin password"
  default = "password"
  sensitive = true
}

