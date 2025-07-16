# Specify the libvirt provider
# https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs 
# https://github.com/dmacvicar/terraform-provider-libvirt
terraform {
	required_providers {
		libvirt = {
			source = "dmacvicar/libvirt"
		}
	}
}

# Configure the Libvirt provider for local system
provider "libvirt" {
	uri = "qemu:///system"
}

locals {
	name			= "tunnel-a"
	base_volume_name	= "vyos-base"
}

resource "libvirt_cloudinit_disk" "seedinit" {
	name		= "seed.iso"
	user_data	= data.template_file.user_data.rendered
}

data "template_file" "user_data" {
	template = file("user-data.cfg")
}

resource "libvirt_volume" "primary" {
	name			= local.name
	pool			= "default"
	base_volume_name	= local.base_volume_name
}

# Create a new domain - boot from alpine iso URL
resource "libvirt_domain" "vm" {
	name	= local.name
	cpu {
		mode = "host-passthrough"
	}
	vcpu	= 2
	memory	= 4096
	console {
		type        = "pty"
		target_port = "0"
	}
	autostart = true
	cloudinit = libvirt_cloudinit_disk.seedinit.id
	disk {
		volume_id	= libvirt_volume.primary.id
	}
	boot_device {
		dev = [ "hd", "cdrom" ]
	}
	network_interface {
		network_name	= "default"
		wait_for_lease	= true
	}
	network_interface {
		network_name	= "net2"
	}
	network_interface {
		network_name	= "net3"
	}
}

output "domain_id" {
	value = libvirt_domain.vm.id
}

output "domain_address" {
	value = libvirt_domain.vm.network_interface.0.addresses.0
}

