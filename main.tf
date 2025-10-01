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
provider "libvirt" {
	uri = "qemu:///system"
}

locals {
	hostname		= var.hostname
	nic_list		= var.nic_list
	base_volume_name	= "vyos-base"
	userdata_template	= "${path.module}/userdata.cfg.tpl"
}

resource "libvirt_cloudinit_disk" "seedinit" {
	name		= "${local.hostname}-seed.iso"
	user_data	= templatefile(local.userdata_template, {
		hostname	= local.hostname
	})
}

resource "libvirt_volume" "primary" {
	name			= local.hostname
	pool			= "default"
	base_volume_name	= local.base_volume_name
}

# Create a new domain - boot from alpine iso URL
resource "libvirt_domain" "vm" {
	name	= local.hostname
	cpu {
		mode = "host-passthrough"
	}
	vcpu	= 2
	memory	= 2048
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

	# mgmt nic
	network_interface {
		network_name	= "default"
		wait_for_lease	= true
	}
	
	# dataplane nics
	dynamic "network_interface" {
		for_each = local.nic_list
		content {
			network_name = network_interface.value.network_name
		}
	}
}

output "hostname" {
	value = local.hostname
}

output "address" {
	value = libvirt_domain.vm.network_interface.0.addresses.0
}
