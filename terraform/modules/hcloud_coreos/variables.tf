variable "name" {
  type        = string
  description = "Instance name"
}

variable "dns_domain" {
  type        = string
  description = "DNS domain"
}

variable "dns_zone_id" {
  description = "Zone ID"
  default     = null
}

variable "dns_internal_ip" {
  description = "Point DNS record to internal ip"
  default     = false
}

variable "instance_count" {
  type        = number
  description = "Number of instances to deploy"
  default     = 1
}

variable "server_type" {
  type        = string
  description = "Hetzner Cloud instance type"
  default     = "cx11"
}

variable "image" {
  type        = string
  description = "Hetzner Cloud system image"
  default     = "ubuntu-22.04"
}

variable "user_data" {
  description = "Cloud-Init user data to use during server creation"
  default     = null
}

variable "ssh_keys" {
  type        = list(any)
  description = "SSH key IDs or names which should be injected into the server at creation time"
  default     = ["default"] # populated to avoid hetzner server creation emails
}

variable "keep_disk" {
  type        = bool
  description = "If true, do not upgrade the disk. This allows downgrading the server type later."
  default     = true
}

variable "location" {
  type        = string
  description = "The location name to create the server in. nbg1, fsn1 or hel1"
  default     = "nbg1"
}

variable "labels" {
  type        = map(string)
  description = "Labels that the instance is tagged with."
  default     = {}
}

variable "backups" {
  type        = bool
  description = "Enable or disable backups"
  default     = false
}

variable "firewall_ids" {
  type        = list(number)
  description = "Assigned firewalls"
  default     = []
}

variable "volume" {
  type        = bool
  description = "Enable or disable an additional volume"
  default     = false
}

variable "volume_size" {
  type        = number
  description = "Size of the additional data volume"
  default     = 20
}

variable "ignition_url" {
  type        = string
  description = "URL to the external ignition webserver"
}

variable "ignition_cacert" {
  type        = string
  description = "CA certificate for the machine config server"
  default     = ""
}

variable "subnet" {
  type        = string
  description = "Id of the additional internal network"
}

variable "image_name" {
  type        = string
  description = "Either fcos or rhcos (necessary for ignition rendering)"
  default     = "fcos"
}

variable "ignition_version" {
  type        = string
  description = "Ignition Version"
  default     = "3.2.0"
}
