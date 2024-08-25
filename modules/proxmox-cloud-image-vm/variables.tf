#### PVE create VM (general) Variable ####
variable "pve_node_name" {
  type        = string
  description = "The name of the PVE node create VM in"
  default     = "pve"
}

variable "on_boot" {
  type        = bool
  description = "Start the VM on PVE node boot"
  default     = true
}

variable "vm_id" {
  type        = number
  description = "The VM ID"
  default     = 8000
}

variable "vm_name" {
  type        = string
  description = "The name of the VM"
  default     = "vyos-builder"
}

variable "vm_tags" {
  type        = list(string)
  description = "The tags for the VM"
  default     = ["terraform-managed"]
}


#### PVE create VM (CPU & memory) Variable ####
variable "cpu" {
  type        = number
  description = "The number of CPUs for the VM"
  default     = 2
}

variable "cpu_type" {
  type        = string
  description = "The CPU type for the VM"
  default     = "qemu64"
}

variable "memory" {
  type        = number
  description = "The amount of memory for the VM"
  default     = 2048
}

#### PVE create VM (disk) variable ####
variable "os_datastore_lvm_name" {
  type        = string
  description = "The name of the LVM datastore for the OS"
  default     = "local-lvm"
}

variable "disk_size" {
  type        = number
  description = "The size of the disk"
  default     = 8
}

#### PVE create VM (network) variable ####
variable "bridge_name" {
  type        = string
  description = "The bridge name"
  default     = "vmbr0"
}

variable "dhcp" {
  type        = bool
  description = "Use DHCP for the IP address"
  default     = false
}

variable "ip" {
  type        = string
  description = "The IP address for the VM"
  default     = ""
}

variable "cidr" {
  type        = string
  description = "The CIDR for the VM"
  default     = ""
}

variable "gateway" {
  type        = string
  description = "The gateway address for the VM"
  default     = ""
}

variable "dns_servers" {
  type        = list(string)
  description = "The DNS servers"
  default     = ["1.1.1.1", "8.8.8.8"]
}

#### PVE create VM (cloud-image) variable ####
variable "cloud_image_file_id" {
  type        = string
  description = "The cloud image file ID"
}

#### PVE create VM (cloud-init) variable ####
variable "cloud_config_datastore_name" {
  type        = string
  description = "The name of the datastore for the cloud config file (Content type snippets must be enabled)"
  default     = "local"
}

variable "vm_user" {
  type        = string
  description = "The default user for VM"
  default     = "ubuntu"
}

variable "vm_user_password" {
  type        = string
  description = "The password for logging in"
  default     = "password"
}

variable "fqdn" {
  type        = string
  description = "The FQDN of the VM"
  default     = "vyos-builder.local"
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

variable "ssh_public_key_content" {
  type        = string
  description = "The public key"
  default     = ""
}

variable "ssh_pwauth" {
  type        = bool
  description = "Enable password authentication"
  default     = false
}
