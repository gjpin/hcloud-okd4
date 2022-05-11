terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "3.14.0"
    }
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.33.2"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.2.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.3"
    }
  }
  required_version = ">= 0.14"
}
