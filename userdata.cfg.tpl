#cloud-config
vyos_config_commands:
  - set system host-name '${hostname}'
  - set vrf name mgmt table '100'
  - delete interfaces ethernet eth0 address 'dhcp'
  - set interfaces ethernet eth0 vrf 'mgmt'
  - set interfaces ethernet eth0 address 'dhcp'
  - set service ssh vrf 'mgmt'
