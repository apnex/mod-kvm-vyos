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

# Create a base vyos disk
resource "libvirt_volume" "vyos-base" {
	name	= "vyos-base"
	pool	= "default"
	format	= "qcow2"
	source	= "vyos-1.4.0.qcow2"
}
