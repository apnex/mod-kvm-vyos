## SYN

### main.tf
```
locals {
	hostname	= "router-a"
	nic_list	= [
		{
			network_name = "net2"
		},
		{
			network_name = "net3"
		},
		{
			network_name = "net4"
		}
	]
}

module "router" {
	source		= "github.com/apnex/mod-kvm-vyos"
	hostname	= local.hostname
	nic_list	= local.nic_list
}

output "router_address" {
	value = module.router.address
}

output "router_hostname" {
	value = module.router.hostname
}
```

### apply
```
terraform init
terraform plan
terraform apply -auto-approve
```
